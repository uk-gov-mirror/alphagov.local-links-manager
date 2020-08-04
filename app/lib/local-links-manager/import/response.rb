module LocalLinksManager
  module Import
    class Response
      attr_accessor :errors

      def initialize
        @errors = []
      end

      def successful?
        @errors.empty?
      end

      def message
        successful? ? "Success" : @errors.join("\n")
      end
    end
  end
end
