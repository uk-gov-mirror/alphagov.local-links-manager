require_relative 'csv_downloader'

module LocalLinksManager
  module Import
    class ServiceInteractionsImporter
      CSV_URL = "http://standards.esd.org.uk/csv?uri=list/englishAndWelshServices&mappedToUri=list/interactions"
      class MissingRecordError < RuntimeError; end
      class MissingIdentifierError < RuntimeError; end

      def self.import
        new.import_records
      end

      def initialize(csv_downloader = CsvDownloader.new(CSV_URL))
        @csv_downloader = csv_downloader
      end

      def import_records
        @csv_downloader.download.each do |row|
          begin
            create_or_update_record(find_associated_records(parsed_hash(row)))
          rescue MissingRecordError, MissingIdentifierError => e
            Rails.logger.error e.message
          end
        end
      rescue CsvDownloader::Error => e
        Rails.logger.error e.message
      rescue => e
        Rails.logger.error "Error #{e.class} importing in #{self.class}\n#{e.backtrace.join("\n")}"
      end

    private

      def parsed_hash(row)
        raise MissingIdentifierError, missing_id_error_msg(Service) if row["Identifier"].nil?
        raise MissingIdentifierError, missing_id_error_msg(Interaction) if row["Mapped identifier"].nil?

        {
          lgsl_code: row["Identifier"],
          lgil_code: row["Mapped identifier"]
        }
      end

      def find_associated_records(parsed_hash)
        service = Service.find_by(lgsl_code: parsed_hash[:lgsl_code])
        interaction = Interaction.find_by(lgil_code: parsed_hash[:lgil_code])

        raise MissingRecordError, missing_record_error_msg(Service, :lgsl_code, parsed_hash[:lgsl_code]) unless service
        raise MissingRecordError, missing_record_error_msg(Interaction, :lgil_code, parsed_hash[:lgil_code]) unless interaction

        { service_id: service.id, interaction_id: interaction.id }
      end

      def missing_id_error_msg(klass)
        "ServiceInteraction could not be created due to missing #{klass.name} identifier in CSV row"
      end

      def missing_record_error_msg(klass, id_type, id)
        "ServiceInteraction could not be created due to missing #{klass.name} (#{id_type}: #{id})"
      end

      def create_or_update_record(parsed_hash)
        service_interaction = ServiceInteraction.where(
          service_id: parsed_hash[:service_id],
          interaction_id: parsed_hash[:interaction_id]
        ).first_or_initialize

        verb = service_interaction.persisted? ? "Updating" : "Creating"
        Rails.logger.info("#{verb} ServiceInteraction (service_id #{parsed_hash[:service_id]}, interaction_id: #{parsed_hash[:interaction_id]})")

        service_interaction.save!
      end
    end
  end
end
