module LocalLinksManager
  module Import
    class Summariser
      def initialize(name, import_source_name)
        @name = name
        @import_source_name = import_source_name

        @import_source_count = 0
        @missing_record_count = 0
        @missing_id_count = 0
        @invalid_record_count = 0
        @updated_record_count = 0
        @created_record_count = 0
        @ignored_items_count = 0
        @extra_summary = ''
      end

      def increment_import_source_count
        @import_source_count += 1
      end

      def increment_missing_record_count
        @missing_record_count += 1
      end

      def increment_missing_id_count
        @missing_id_count += 1
      end

      def increment_invalid_record_count
        @invalid_record_count += 1
      end

      def increment_updated_record_count
        @updated_record_count += 1
      end

      def increment_created_record_count
        @created_record_count += 1
      end

      def increment_ignored_items_count
        @ignored_items_count += 1
      end

      def add_summary(extra_summary_text)
        @extra_summary << extra_summary_text
      end

      def summary
        "#{@name} complete\n"\
        "#{@data_items_name}: #{@data_items_count}\n"\
        "Updated records: #{@updated_record_count}\n"\
        "Ignored source items: #{@ignored_items_count}\n"\
        "Import errors with missing Identifier: #{@missing_id_count}\n"\
        "Import errors with missing associated Record: #{@missing_record_count}\n"\
        "Import errors with invalid values for updating record: #{@invalid_record_count}\n"\
        "#{@extra_summary}\n"
      end

      def counting_errors(errors_collector, &block)
        block.call
      rescue MissingRecordError => e
        increment_missing_record_count
        Rails.logger.error e.message
        errors_collector.errors << e.message
      rescue MissingIdentifierError => e
        increment_missing_id_count
        Rails.logger.error e.message
        errors_collector.errors << e.message
      rescue ActiveRecord::RecordInvalid => e
        increment_invalid_record_count
        Rails.logger.error e.message
        errors_collector.errors << e.message
      end
    end
  end
end
