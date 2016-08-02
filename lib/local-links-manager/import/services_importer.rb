require_relative 'csv_downloader'
require_relative 'import_comparer'
require_relative 'response'
require_relative 'error_message_formatter'

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
      end

      def import_records
        response = Response.new

        begin
          @csv_downloader.each_row do |row|
            service = create_or_update_record(row)
            @comparer.add_source_record(service.lgsl_code)
          end

          missing = @comparer.check_missing_records(Service.all, &:lgsl_code)

          response.errors << error_message(missing) unless missing.empty?
        rescue CsvDownloader::Error => e
          Rails.logger.error e.message
          response.errors << e.message
        rescue => e
          error_message = "Error #{e.class} importing in #{self.class}\n#{e.backtrace.join("\n")}"
          Rails.logger.error error_message
          response.errors << error_message
        end

        response
      end

    private

      def create_or_update_record(row)
        service = Service.where(lgsl_code: row[:lgsl_code]).first_or_initialize
        verb = service.persisted? ? "Updating" : "Creating"
        Rails.logger.info("#{verb} service '#{row[:label]}' (lgsl #{row[:lgsl_code]})")

        service.label = row[:label]
        service.slug = row[:label].parameterize
        service.save!
        service
      end

      def error_message(missing)
        ErrorMessageFormatter.new('Service', "no longer in the import source.", missing).message
      end
    end
  end
end
