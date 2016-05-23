require_relative 'csv_downloader'

module LocalLinksManager
  module Import
    class ServicesTierImporter
      CSV_URL = "https://raw.githubusercontent.com/alphagov/publisher/master/data/local_services.csv"
      FIELD_NAME_CONVERSIONS = {
        'LGSL' => :lgsl_code,
        'Providing Tier' => :tier,
      }
      class MissingRecordError < RuntimeError; end
      class MissingIdentifierError < RuntimeError; end

      def self.import
        new.import_tiers
      end

      def initialize(csv_downloader = CsvDownloader.new(CSV_URL, header_conversions: FIELD_NAME_CONVERSIONS))
        @csv_downloader = csv_downloader
        @csv_rows = 0
        @missing_record_count = 0
        @missing_id_count = 0
        @invalid_record_count = 0
        @updated_record_count = 0
        @ignored_rows_count = 0
      end

      def import_tiers
        with_each_csv_row do |row|
          counting_errors do
            if update_record(row)
              @updated_record_count += 1
            else
              @ignored_rows_count += 1
            end
          end
        end
        Rails.logger.info import_summary
      end

    private

      def import_summary
        "ServicesTier Import complete\n"\
        "Downloaded CSV rows: #{@csv_rows}\n"\
        "Updated records: #{@updated_record_count}\n"\
        "Ignored rows: #{@ignored_rows_count}\n"\
        "Import errors with missing Identifier: #{@missing_id_count}\n"\
        "Import errors with missing associated Record: #{@missing_record_count}\n"\
        "Import errors with invalid values for updating record: #{@invalid_record_count}\n"
      end

      def update_record(row)
        raise MissingIdentifierError if row[:lgsl_code].blank?
        service = Service.find_by(lgsl_code: row[:lgsl_code])
        raise MissingRecordError if service.nil?
        Rails.logger.info("Updating service '#{service.label}' (lgsl #{service.lgsl_code})")

        unless row[:tier].blank?
          service.tier = row[:tier]
          service.save!
        end
      end

      def with_each_csv_row(&block)
        @csv_downloader.each_row do |row|
          @csv_rows += 1
          block.call(row)
        end
      rescue CsvDownloader::Error => e
        Rails.logger.error e.message
      rescue => e
        Rails.logger.error "Error #{e.class} importing in #{self.class}\n#{e.backtrace.join("\n")}"
      end

      def counting_errors(&block)
        block.call
      rescue MissingRecordError => e
        @missing_record_count += 1
        Rails.logger.error e.message
      rescue MissingIdentifierError => e
        @missing_id_count += 1
        Rails.logger.error e.message
      rescue ActiveRecord::RecordInvalid => e
        @invalid_record_count += 1
        Rails.logger.error e.message
      end
    end
  end
end
