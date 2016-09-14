module LocalLinksManager
  module Import
    class ImportComparer
      def initialize
        @records_in_source = Set.new
        @missing = Set.new
      end

      def add_source_record(record_key)
        @records_in_source.add(record_key)
      end

      def check_missing_records(saved_records)
        saved_records.each do |record|
          record_key = yield(record)
          unless @records_in_source.include? record_key
            @missing.add(record_key)
          end
        end

        @missing
      end
    end
  end
end
