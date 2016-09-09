require_relative 'csv_downloader'
require_relative 'import_comparer'
require_relative 'response'
require_relative 'error_message_formatter'
require_relative 'errors'

module LocalLinksManager
  module Import
    class ServicesImporter
      CSV_URL = "http://standards.esd.org.uk/csv?uri=list/englishAndWelshServices"
      FIELD_NAME_CONVERSIONS = {
        "Label" => :label,
        "Identifier" => :lgsl_code
      }

      def self.import
        new.import_records
      end

      def initialize(
        csv_downloader = CsvDownloader.new(CSV_URL, header_conversions: FIELD_NAME_CONVERSIONS),
        import_comparer = ImportComparer.new
        )

        @csv_downloader = csv_downloader
        @comparer = import_comparer

        @csv_rows = 0
        @missing_id_count = 0
        @invalid_record_count = 0
        @created_record_count = 0
        @updated_record_count = 0
      end

      def import_records
        @response = Response.new

        with_each_csv_row do |row|
          counting_errors do
            service = create_or_update_record(row)
            @comparer.add_source_record(service.lgsl_code)
          end
        end

        missing = @comparer.check_missing_records(Service.all, &:lgsl_code)

        @response.errors << error_message(missing) unless missing.empty?

        Rails.logger.info import_summary

        @response
      end

    private

      def import_summary
        "Services Import complete\n"\
        "Downloaded CSV rows: #{@csv_rows}\n"\
        "Created records: #{@created_record_count}\n"\
        "Updated records: #{@updated_record_count}\n"\
        "Import errors with missing Identifier: #{@missing_id_count}\n"\
        "Import errors with invalid values for record: #{@invalid_record_count}\n"
      end

      def create_or_update_record(row)
        raise MissingIdentifierError if row[:lgsl_code].blank?
        service = Service.where(lgsl_code: row[:lgsl_code]).first_or_initialize
        existing_record = service.persisted?
        verb = existing_record ? "Updating" : "Creating"
        Rails.logger.info("#{verb} service '#{row[:label]}' (lgsl #{row[:lgsl_code]})")

        service.label = row[:label]
        service.slug = row[:label].parameterize
        service.save!
        if existing_record
          @updated_record_count += 1
        else
          @created_record_count += 1
        end
        service
      end

      def with_each_csv_row(&block)
        @csv_downloader.each_row do |row|
          @csv_rows += 1
          block.call(row)
        end
      rescue CsvDownloader::Error => e
        Rails.logger.error e.message
        @response.errors << e.message
      rescue => e
        error_message = "Error #{e.class} importing in #{self.class}\n#{e.backtrace.join("\n")}"
        Rails.logger.error error_message
        @response.errors << error_message
      end

      def counting_errors(&block)
        block.call
      rescue MissingIdentifierError => e
        @missing_id_count += 1
        Rails.logger.error e.message
        @response.errors << e.message
      rescue ActiveRecord::RecordInvalid => e
        @invalid_record_count += 1
        Rails.logger.error e.message
        @response.errors << e.message
      end

      def error_message(missing)
        ErrorMessageFormatter.new('Service', "no longer in the import source.", missing).message
      end
    end
  end
end
