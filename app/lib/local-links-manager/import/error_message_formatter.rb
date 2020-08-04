module LocalLinksManager
  module Import
    class ErrorMessageFormatter
      def initialize(klass, suffix, entries)
        @klass = klass
        @suffix = suffix
        @entries = entries
      end

      def message
        if @entries.count == 1
          "1 #{@klass} is #{@suffix}\n#{list_entries(@entries)}\n"
        else
          "#{@entries.count} #{@klass.pluralize} are #{@suffix}\n#{list_entries(@entries)}\n"
        end
      end

    private

      def list_entries(entries)
        entries.to_a.sort.join("\n")
      end
    end
  end
end
