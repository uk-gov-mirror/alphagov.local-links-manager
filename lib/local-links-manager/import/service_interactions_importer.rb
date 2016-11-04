require_relative 'csv_downloader'
require_relative 'processor'
require_relative 'error_message_formatter'
require_relative 'errors'

module LocalLinksManager
  module Import
    class ServiceInteractionsImporter
      CSV_URL = "http://standards.esd.org.uk/csv?uri=list/englishAndWelshServices&mappedToUri=list/interactions".freeze
      FIELD_NAME_CONVERSIONS = {
        "Identifier" => :lgsl_code,
        "Mapped identifier" => :lgil_code,
      }.freeze

      def self.import
        new.import_records
      end

      def initialize(
          csv_downloader = CsvDownloader.new(CSV_URL, header_conversions: FIELD_NAME_CONVERSIONS),
          import_comparer = ImportComparer.new
        )
        @csv_downloader = csv_downloader
        @comparer = import_comparer
      end

      def import_records
        Processor.new(self).process
      end

      def each_item(&block)
        @csv_downloader.each_row(&block)
      end

      def import_item(item, _response, summariser)
        create_or_update_record(find_associated_records(item), summariser)
        @comparer.add_source_record("#{item[:lgsl_code]}_#{item[:lgil_code]}")
      end

      def all_items_imported(response, _summariser)
        missing = @comparer.check_missing_records(ServiceInteraction.all) { |x| "#{x.lgsl_code}_#{x.lgil_code}" }

        response.errors << error_message(missing) unless missing.empty?
      end

      def import_name
        'ServiceInteraction Import'
      end

      def import_source_name
        'Downloaded CSV rows'
      end

    private

      def find_associated_records(item)
        raise MissingIdentifierError, missing_id_error_msg(Service) if item[:lgsl_code].nil?
        raise MissingIdentifierError, missing_id_error_msg(Interaction) if item[:lgil_code].nil?

        service = Service.find_by(lgsl_code: item[:lgsl_code])
        interaction = Interaction.find_by(lgil_code: item[:lgil_code])

        raise MissingRecordError, missing_record_error_msg(Service, :lgsl_code, item[:lgsl_code]) unless service
        raise MissingRecordError, missing_record_error_msg(Interaction, :lgil_code, item[:lgil_code]) unless interaction

        { service_id: service.id, interaction_id: interaction.id }
      end

      def missing_id_error_msg(klass)
        "ServiceInteraction could not be created due to missing #{klass.name} identifier in CSV row"
      end

      def missing_record_error_msg(klass, id_type, id)
        "ServiceInteraction could not be created due to missing #{klass.name} (#{id_type}: #{id})"
      end

      def create_or_update_record(item, summariser)
        service_interaction = ServiceInteraction.where(
          service_id: item[:service_id],
          interaction_id: item[:interaction_id]
        ).first_or_initialize

        existing_record = service_interaction.persisted?
        verb = existing_record ? "Updating" : "Creating"
        Rails.logger.info("#{verb} ServiceInteraction (service_id #{item[:service_id]}, interaction_id: #{item[:interaction_id]})")

        service_interaction.save!
        if existing_record
          summariser.increment_updated_record_count
        else
          summariser.increment_created_record_count
        end
        service_interaction
      end

      def error_message(missing)
        ErrorMessageFormatter.new('ServiceInteraction', "no longer in the import source.", missing).message
      end
    end
  end
end
