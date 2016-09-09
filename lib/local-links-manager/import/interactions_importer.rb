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
      class MissingIdentifierError < RuntimeError; end

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
            interaction = create_or_update_record(row)
            @comparer.add_source_record(interaction.lgil_code)
          end
        end

        missing = @comparer.check_missing_records(Interaction.all, &:lgil_code)

        @response.errors << error_message(missing) unless missing.empty?

        Rails.logger.info import_summary

        @response
      end

    private

      def import_summary
        "Interactions Import complete\n"\
        "Downloaded CSV rows: #{@csv_rows}\n"\
        "Created records: #{@created_record_count}\n"\
        "Updated records: #{@updated_record_count}\n"\
        "Import errors with missing Identifier: #{@missing_id_count}\n"\
        "Import errors with invalid values for record: #{@invalid_record_count}\n"
      end

      def create_or_update_record(row)
        raise MissingIdentifierError if row[:lgil_code].blank?
        interaction = Interaction.where(lgil_code: row[:lgil_code]).first_or_initialize
        existing_record = interaction.persisted?
        verb = existing_record ? "Updating" : "Creating"
        Rails.logger.info("#{verb} interaction '#{row[:label]}' (lgsl #{row[:lgil_code]})")

        interaction.label = row[:label]
        interaction.slug = row[:label].parameterize
        interaction.save!
        if existing_record
          @updated_record_count += 1
        else
          @created_record_count += 1
        end
        interaction
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
        ErrorMessageFormatter.new('Interaction', "no longer in the import source.", missing).message
      end
    end
  end
end
