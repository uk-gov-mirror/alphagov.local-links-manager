require_relative 'csv_downloader'

module LocalLinksManager
  module Import
    class ServiceInteractionsImporter
      CSV_URL = "http://standards.esd.org.uk/csv?uri=list/englishAndWelshServices&mappedToUri=list/interactions"
      FIELD_NAME_CONVERSIONS = {
        "Identifier" => :lgsl_code,
        "Mapped identifier" => :lgil_code,
      }

      class MissingRecordError < RuntimeError; end
      class MissingIdentifierError < RuntimeError; end

      def self.import
        new.import_records
      end

      def initialize(csv_downloader = CsvDownloader.new(CSV_URL, header_conversions: FIELD_NAME_CONVERSIONS))
        @csv_downloader = csv_downloader
        @csv_rows = 0
        @missing_record_count = 0
        @missing_id_count = 0
        @created_or_updated_record_count = 0
      end

      def import_records
        @csv_downloader.each_row do |row|
          @csv_rows += 1
          begin
            create_or_update_record(find_associated_records(row))
            @created_or_updated_record_count += 1
          rescue MissingRecordError => e
            @missing_record_count += 1
            Rails.logger.error e.message
          rescue MissingIdentifierError => e
            @missing_id_count += 1
            Rails.logger.error e.message
          end
        end
        Rails.logger.info import_summary
      rescue CsvDownloader::Error => e
        Rails.logger.error e.message
      rescue => e
        Rails.logger.error "Error #{e.class} importing in #{self.class}\n#{e.backtrace.join("\n")}"
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

        verb = service_interaction.persisted? ? "Updating" : "Creating"
        Rails.logger.info("#{verb} ServiceInteraction (service_id #{row[:service_id]}, interaction_id: #{row[:interaction_id]})")

        service_interaction.save!
      end

      def import_summary
        "ServiceInteraction Import complete\n"\
        "Downloaded CSV rows: #{@csv_rows}\n"\
        "Created or updated records: #{@created_or_updated_record_count}\n"\
        "Import errors with missing Identifier: #{@missing_id_count}\n"\
        "Import errors with missing associated Record: #{@missing_record_count}\n"
      end
    end
  end
end
