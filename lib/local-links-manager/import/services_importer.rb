require_relative 'csv_downloader'
require_relative 'import_comparer'
require_relative 'processor'
require_relative 'error_message_formatter'
require_relative 'errors'

module LocalLinksManager
  module Import
    class ServicesImporter
      CSV_URL = "http://standards.esd.org.uk/csv?uri=list/englishAndWelshServices".freeze
      FIELD_NAME_CONVERSIONS = {
        "Label" => :label,
        "Identifier" => :lgsl_code
      }.freeze

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
        Processor.new(self).process
      end

      def each_item(&block)
        @csv_downloader.each_row(&block)
      end

      def import_item(item, _response, summariser)
        service = create_or_update_record(item, summariser)
        @comparer.add_source_record(service.lgsl_code)
      end

      def all_items_imported(response, _summariser)
        missing = @comparer.check_missing_records(Service.all, &:lgsl_code)

        response.errors << error_message(missing) unless missing.empty?
      end

      def import_name
        'Services Import'
      end

      def import_source_name
        'Downloaded CSV rows'
      end

    private

      def create_or_update_record(item, summariser)
        raise MissingIdentifierError if item[:lgsl_code].blank?
        service = Service.where(lgsl_code: item[:lgsl_code]).first_or_initialize
        existing_record = service.persisted?
        verb = existing_record ? "Updating" : "Creating"
        Rails.logger.info("#{verb} service '#{item[:label]}' (lgsl #{item[:lgsl_code]})")

        service.label = item[:label]
        service.slug = item[:label].parameterize
        service.save!
        if existing_record
          summariser.increment_updated_record_count
        else
          summariser.increment_created_record_count
        end
        service
      end

      def error_message(missing)
        ErrorMessageFormatter.new('Service', "no longer in the import source.", missing).message
      end
    end
  end
end
