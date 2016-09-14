require_relative 'csv_downloader'
require_relative 'processor'
require_relative 'errors'

module LocalLinksManager
  module Import
    class ServicesTierImporter
      CSV_URL = "https://raw.githubusercontent.com/alphagov/publisher/master/data/local_services.csv"
      FIELD_NAME_CONVERSIONS = {
        'LGSL' => :lgsl_code,
        'Providing Tier' => :tier,
      }

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
        'ServiceTier import'
      end

      def import_source_name
        'Downloaded CSV rows'
      end

      def each_item(&block)
        @csv_downloader.each_row(&block)
      end

      def import_item(item, response, summariser)
        raise MissingIdentifierError if item[:lgsl_code].blank?
        service = Service.find_by(lgsl_code: item[:lgsl_code])
        raise MissingRecordError, "LGSL #{item[:lgsl_code]} is missing" if service.nil?
        Rails.logger.info("Updating service '#{service.label}' (lgsl #{service.lgsl_code})")

        if item[:tier].blank?
          response.errors << "LGSL #{item[:lgsl_code]} is missing a tier"
          summariser.increment_ignored_items_count
        else
          service.tier = item[:tier]
          service.save!
          summariser.increment_updated_record_count
        end
      end
    end
  end
end
