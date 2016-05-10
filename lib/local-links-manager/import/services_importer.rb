require_relative 'csv_downloader'

module LocalLinksManager
  module Import
    class ServicesImporter
      CSV_URL = "http://standards.esd.org.uk/csv?uri=list/englishAndWelshServices"

      def self.import
        new.import_records
      end

      def initialize(csv_downloader = CsvDownloader.new(CSV_URL))
        @csv_downloader = csv_downloader
      end

      def import_records
        @csv_downloader.download.each { |row| create_or_update_record(parsed_hash(row)) }
      rescue CsvDownloader::Error => e
        Rails.logger.error e.message
      rescue => e
        Rails.logger.error "Error #{e.class} importing in #{self.class}\n#{e.backtrace.join("\n")}"
      end

    private

      def parsed_hash(row)
        {
          label: row["Label"],
          lgsl_code: row["Identifier"]
        }
      end

      def create_or_update_record(parsed_hash)
        service = Service.where(lgsl_code: parsed_hash[:lgsl_code]).first_or_initialize
        verb = service.persisted? ? "Updating" : "Creating"
        Rails.logger.info("#{verb} service '#{parsed_hash[:label]}' (lgsl #{parsed_hash[:lgsl_code]})")

        service.label = parsed_hash[:label]
        service.save!
      end
    end
  end
end
