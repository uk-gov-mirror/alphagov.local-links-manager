require_relative 'csv_downloader'
require_relative 'response'
require_relative 'error_message_formatter'
require_relative 'errors'

module LocalLinksManager
  module Import
    class ServiceInteractionsImporter
      CSV_URL = "http://standards.esd.org.uk/csv?uri=list/englishAndWelshServices&mappedToUri=list/interactions"
      FIELD_NAME_CONVERSIONS = {
        "Identifier" => :lgsl_code,
        "Mapped identifier" => :lgil_code,
      }

      def self.import
        new.import_records
      end

      def initialize(
          csv_downloader = CsvDownloader.new(CSV_URL, header_conversions: FIELD_NAME_CONVERSIONS),
          import_comparer = ImportComparer.new
        )
        @csv_downloader = csv_downloader
        @csv_rows = 0
        @missing_record_count = 0
        @missing_id_count = 0
        @created_record_count = 0
        @updated_record_count = 0
        @comparer = import_comparer
      end

      def import_records
        @response = Response.new

        with_each_csv_row do |row|
          counting_errors do
            create_or_update_record(find_associated_records(row))
            @comparer.add_source_record("#{row[:lgsl_code]}_#{row[:lgil_code]}")
          end
        end

        missing = @comparer.check_missing_records(ServiceInteraction.all) { |x| "#{x.lgsl_code}_#{x.lgil_code}" }

        @response.errors << error_message(missing) unless missing.empty?

        Rails.logger.info import_summary

        @response
      end

    private

      def find_associated_records(row)
        raise MissingIdentifierError, missing_id_error_msg(Service) if row[:lgsl_code].nil?
        raise MissingIdentifierError, missing_id_error_msg(Interaction) if row[:lgil_code].nil?

        service = Service.find_by(lgsl_code: row[:lgsl_code])
        interaction = Interaction.find_by(lgil_code: row[:lgil_code])

        raise MissingRecordError, missing_record_error_msg(Service, :lgsl_code, row[:lgsl_code]) unless service
        raise MissingRecordError, missing_record_error_msg(Interaction, :lgil_code, row[:lgil_code]) unless interaction

        { service_id: service.id, interaction_id: interaction.id }
      end

      def missing_id_error_msg(klass)
        "ServiceInteraction could not be created due to missing #{klass.name} identifier in CSV row"
      end

      def missing_record_error_msg(klass, id_type, id)
        "ServiceInteraction could not be created due to missing #{klass.name} (#{id_type}: #{id})"
      end

      def create_or_update_record(row)
        service_interaction = ServiceInteraction.where(
          service_id: row[:service_id],
          interaction_id: row[:interaction_id]
        ).first_or_initialize

        existing_record = service_interaction.persisted?
        verb = existing_record ? "Updating" : "Creating"
        Rails.logger.info("#{verb} ServiceInteraction (service_id #{row[:service_id]}, interaction_id: #{row[:interaction_id]})")

        service_interaction.save!
        if existing_record
          @updated_record_count += 1
        else
          @created_record_count += 1
        end
        service_interaction
      end

      def import_summary
        "ServiceInteraction Import complete\n"\
        "Downloaded CSV rows: #{@csv_rows}\n"\
        "Created records: #{@created_record_count}\n"\
        "Updated records: #{@updated_record_count}\n"\
        "Import errors with missing Identifier: #{@missing_id_count}\n"\
        "Import errors with missing associated Record: #{@missing_record_count}\n"\
        "Import errors with invalid values for record: #{@invalid_record_count}\n"
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
      rescue MissingRecordError => e
        @missing_record_count += 1
        Rails.logger.error e.message
        @response.errors << e.message
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
        ErrorMessageFormatter.new('ServiceInteraction', "no longer in the import source.", missing).message
      end
    end
  end
end
