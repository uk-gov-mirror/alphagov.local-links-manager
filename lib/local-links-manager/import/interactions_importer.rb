require_relative 'csv_downloader'
require_relative 'response'
require_relative 'error_message_formatter'

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
        import_comparer = ImportComparer.new
        )

        @csv_downloader = csv_downloader
        @comparer = import_comparer
      end

      def import_records
        response = Response.new

        begin
          @csv_downloader.each_row do |row|
            interaction = create_or_update_record(row)
            @comparer.add_source_record(interaction.lgil_code)
          end

          missing = @comparer.check_missing_records(Interaction.all, &:lgil_code)

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
        interaction = Interaction.where(lgil_code: row[:lgil_code]).first_or_initialize
        verb = interaction.persisted? ? "Updating" : "Creating"
        Rails.logger.info("#{verb} interaction '#{row[:label]}' (lgsl #{row[:lgil_code]})")

        interaction.label = row[:label]
        interaction.slug = row[:label].parameterize
        interaction.save!
        interaction
      end

      def error_message(missing)
        ErrorMessageFormatter.new('Interaction', "no longer in the import source.", missing).message
      end
    end
  end
end
