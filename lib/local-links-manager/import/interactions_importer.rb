require_relative 'csv_downloader'

module LocalLinksManager
  module Import
    class InteractionsImporter
      CSV_URL = "http://standards.esd.org.uk/csv?uri=list/interactions"
      FIELD_NAME_CONVERSIONS = {
        "Label" => :label,
        "Identifier" => :lgil_code
      }

      def self.import
        new.import_records
      end

      def initialize(csv_downloader = CsvDownloader.new(CSV_URL, FIELD_NAME_CONVERSIONS))
        @csv_downloader = csv_downloader
      end

      def import_records
        @csv_downloader.download.each { |row| create_or_update_record(row) }
      rescue CsvDownloader::Error => e
        Rails.logger.error e.message
      rescue => e
        Rails.logger.error "Error #{e.class} importing in #{self.class}\n#{e.backtrace.join("\n")}"
      end

    private

      def create_or_update_record(row)
        interaction = Interaction.where(lgil_code: row[:lgil_code]).first_or_initialize
        verb = interaction.persisted? ? "Updating" : "Creating"
        Rails.logger.info("#{verb} interaction '#{row[:label]}' (lgsl #{row[:lgil_code]})")

        interaction.label = row[:label]
        interaction.save!
      end
    end
  end
end
