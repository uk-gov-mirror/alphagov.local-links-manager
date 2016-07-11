require_relative 'csv_downloader'
require_relative 'import_comparer'

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
        import_comparer = ImportComparer.new("service")
        )

        @csv_downloader = csv_downloader
        @comparer = import_comparer
      end

      def import_records
        @csv_downloader.each_row do |row|
          service = create_or_update_record(row)
          @comparer.add_source_record(service.lgsl_code)
        end

        @comparer.check_missing_records(Service.all, &:lgsl_code)
      rescue CsvDownloader::Error => e
        Rails.logger.error e.message
      rescue => e
        Rails.logger.error "Error #{e.class} importing in #{self.class}\n#{e.backtrace.join("\n")}"
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
    end
  end
end
