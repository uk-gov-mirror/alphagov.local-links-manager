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

      def initialize(
        csv_downloader = CsvDownloader.new(CSV_URL, header_conversions: FIELD_NAME_CONVERSIONS),
        import_comparer = ImportComparer.new("interaction")
        )

        @csv_downloader = csv_downloader
        @comparer = import_comparer
      end

      def import_records
        @csv_downloader.each_row do |row|
          interaction = create_or_update_record(row)
          @comparer.add_source_record(interaction.lgil_code)
        end
        @comparer.check_missing_records(Interaction.all, &:lgil_code)
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
        interaction.slug = row[:label].parameterize
        interaction.save!
        interaction
      end
    end
  end
end
