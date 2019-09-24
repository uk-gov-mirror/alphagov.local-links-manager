require_relative "errors"
require_relative "error_message_formatter"
require_relative "import_comparer"
require_relative "processor"
require "gds_api/publishing_api_v2"

module LocalLinksManager
  module Import
    class PublishingApiImporter
      def self.import
        new.import_data
      end

      def initialize(import_comparer = ImportComparer.new)
        @comparer = import_comparer
      end

      def import_data
        Processor.new(self).process
      end

      def each_item(&block)
        local_transactions.each(&block)
      end

      def import_item(local_transaction, _response, summariser)
        raise MissingIdentifierError, "Found empty LGSL/LGIL code on local_transaction #{local_transaction['slug']}" if local_transaction["lgil"].blank? || local_transaction["lgsl"].blank?

        service = Service.find_by(lgsl_code: local_transaction["lgsl"])
        interaction = Interaction.find_by(lgil_code: local_transaction["lgil"])

        service_interaction = ServiceInteraction.find_by(
          service: service,
          interaction: interaction,
        )

        if service_interaction
          service_interaction.update!(
            govuk_slug: local_transaction["slug"],
            govuk_title: local_transaction["title"],
            live: true,
          )

          summariser.increment_updated_record_count
          @comparer.add_source_record(service_interaction.govuk_slug)

          Rails.logger.info("Imported title #{local_transaction['title']} and slug #{local_transaction['slug']} for LGSL #{local_transaction['lgsl']} and LGIL #{local_transaction['lgil']}.")
        else
          Rails.logger.info("Skipped importing for #{local_transaction['slug']} because it refers to an invalid ServiceInteraction")
          summariser.increment_invalid_record_count
        end
      end

      def all_items_imported(response, _summariser)
        missing = @comparer.check_missing_records(ServiceInteraction.where(live: true), &:govuk_slug)
        response.errors << error_message_for_missing(missing) unless missing.empty?
      end

      def import_name
        "Local Transaction information import"
      end

      def import_source_name
        "content items from Publishing API"
      end

    private

      def local_transactions
        @local_transactions ||=
          publishing_api_response
            .to_hash["results"]
            .map do |local_transaction|
              local_transaction_hash(local_transaction)
            end
      end

      def publishing_api_response
        Services.publishing_api.get_content_items(document_type: "local_transaction", per_page: 150)
      end

      def local_transaction_hash(parsed_result)
        local_transaction = {}
        local_transaction["title"] = parsed_result["title"]
        local_transaction["slug"] = parsed_result["base_path"][1..-1]
        local_transaction["lgsl"] = parsed_result["details"]["lgsl_code"]
        local_transaction["lgil"] = parsed_result["details"]["lgil_code"]
        local_transaction
      end

      def error_message_for_missing(missing)
        ErrorMessageFormatter.new("Local Transaction", "no longer in the import source.", missing).message
      end
    end
  end
end
