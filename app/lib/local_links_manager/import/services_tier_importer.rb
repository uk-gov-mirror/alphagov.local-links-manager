require_relative "csv_downloader"
require_relative "processor"
require_relative "errors"
require Rails.root.join("app/models/tier")

module LocalLinksManager
  module Import
    class ServicesTierImporter
      CSV_URL = "https://raw.githubusercontent.com/alphagov/publisher/master/data/local_services.csv".freeze
      FIELD_NAME_CONVERSIONS = {
        "LGSL" => :lgsl_code,
        "Providing Tier" => :tier,
      }.freeze

      def self.import
        new.import_tiers
      end

      def initialize(csv_downloader = CsvDownloader.new(CSV_URL, header_conversions: FIELD_NAME_CONVERSIONS))
        @csv_downloader = csv_downloader
      end

      def import_tiers
        Processor.new(self).process
      end

      def import_name
        "ServiceTier import"
      end

      def import_source_name
        "Downloaded CSV rows"
      end

      def each_item(&block)
        @csv_downloader.each_row(&block)
      end

      def import_item(item, response, summariser)
        raise Errors::MissingIdentifierError if item[:lgsl_code].blank?

        service = Service.find_by(lgsl_code: item[:lgsl_code])
        raise Errors::MissingRecordError, "LGSL #{item[:lgsl_code]} is missing" if service.nil?

        Rails.logger.info("Updating service '#{service.label}' (lgsl #{service.lgsl_code})")
        checked_services.add(service)

        if item[:tier].blank?
          response.errors << "LGSL #{item[:lgsl_code]} is missing a tier"
          summariser.increment_ignored_items_count
        elsif !service.valid_tier?(item[:tier])
          response.errors << "LGSL #{item[:lgsl_code]} has incorrect tier name"
          summariser.increment_ignored_items_count
        else
          service.delete_and_create_tiers(item[:tier])
          summariser.increment_updated_record_count
        end
      end

      def all_items_imported(response, summariser)
        missing = check_for_missing_services(summariser)
        response.errors << error_message(missing) unless missing.empty?
        summariser.add_summary summarise_services_tier_import(missing)
      end

    private

      def checked_services
        @checked_services ||= Set.new
      end

      def check_for_missing_services(summariser)
        missing = []
        Service.enabled.each do |service|
          next if checked_services.include?(service)

          summariser.increment_missing_record_count
          missing << service
          ServiceTier.where(service: service).destroy_all
        end
        missing
      end

      def error_message(missing)
        suffix = "not present in the import."
        deleted = "service tiers have been deleted."
        if missing.count == 1
          "1 Service is #{suffix} Its #{deleted} \n#{list_missing(missing)}\n"
        else
          "#{missing.count} Services are #{suffix} Their #{deleted}\n#{list_missing(missing)}\n"
        end
      end

      def list_missing(missing)
        missing.to_a.sort.join("\n")
      end

      def summarise_services_tier_import(missing)
        suffix = "not present in the import."
        deleted = "service tiers have been deleted."

        result = "Service tiers were successfully imported.\n"

        result += "1 service was #{suffix} Its #{deleted}" if missing.count == 1
        result += "#{missing.count} services where #{suffix} Their #{deleted}" if missing.count > 1
        result
      end
    end
  end
end
