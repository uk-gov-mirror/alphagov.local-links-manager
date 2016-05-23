require_relative 'csv_downloader'

module LocalLinksManager
  module Import
    class LinksImporter
      CSV_URL = 'http://local.direct.gov.uk/Data/local_authority_service_details.csv'
      FIELD_NAME_CONVERSIONS = {
        'SNAC' => :snac,
        'LGSL' => :lgsl_code,
        'LGIL' => :lgil_code,
        'Service URL' => :url
      }

      class MissingRecordError < RuntimeError; end
      class MissingIdentifierError < RuntimeError; end

      def self.import
        new.import_records
      end

      def initialize(csv_downloader = CsvDownloader.new(CSV_URL, header_conversions: FIELD_NAME_CONVERSIONS, encoding: 'windows-1252'))
        @csv_downloader = csv_downloader
        @csv_rows = 0
        @modified_record_count = 0
        @ignored_rows_count = 0
        @missing_record_count = 0
        @missing_id_count = 0
        @invalid_record_count = 0
      end

      def import_records
        with_each_csv_row do |row|
          counting_errors do
            if create_or_update_record(row)
              @modified_record_count += 1
            else
              @ignored_rows_count += 1
            end
          end
        end
        Rails.logger.info import_summary
      end

    private

      def import_summary
        "Links Import complete\n"\
        "Downloaded CSV rows: #{@csv_rows}\n"\
        "Modified records: #{@modified_record_count}\n"\
        "Ignored rows: #{@ignored_rows_count}\n"\
        "Import errors with missing Identifiers: #{@missing_id_count}\n"\
        "Import errors with missing associated Records: #{@missing_record_count}\n"\
        "Import errors with invalid values for modifying record: #{@invalid_record_count}\n"
      end

      def with_each_csv_row(&block)
        @csv_downloader.each_row do |row|
          @csv_rows += 1
          block.call(row)
        end
      rescue CsvDownloader::Error => e
        Rails.logger.error e.message
      rescue => e
        Rails.logger.error "Error #{e.class} importing in #{self.class}\n#{e.backtrace.join("\n")}"
        raise e
      end

      def counting_errors(&block)
        block.call
      rescue MissingRecordError => e
        @missing_record_count += 1
        Rails.logger.error e.message
      rescue MissingIdentifierError => e
        @missing_id_count += 1
        Rails.logger.error e.message
      rescue ActiveRecord::RecordInvalid => e
        @invalid_record_count += 1
        Rails.logger.error e.message
      end

      def create_or_update_record(row)
        raise MissingIdentifierError if [:lgsl_code, :lgil_code, :snac].any? { |field| row[field].blank? }
        service_interaction = ServiceInteraction.find_by_lgsl_and_lgil(row[:lgsl_code], row[:lgil_code])
        local_authority = LocalAuthority.find_by(snac: row[:snac])
        raise MissingRecordError if [service_interaction, local_authority].any?(&:nil?)

        link = Link.where(
          service_interaction_id: service_interaction.id,
          local_authority_id: local_authority.id
        ).first_or_initialize

        verb = link.persisted? ? "Updating" : "Creating"
        Rails.logger.info("#{verb} Link (lgsl #{row[:lgsl_code]}, lgil: #{row[:lgil_code]}, snac: #{row[:snac]})")

        link.url = row[:url]
        link.save!
      end
    end
  end
end
