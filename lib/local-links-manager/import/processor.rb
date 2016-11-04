require_relative 'response'
require_relative 'summariser'

module LocalLinksManager
  module Import
    class Processor
      def initialize(importer)
        @importer = importer
        @response = Response.new
        @summariser = Summariser.new(@importer.import_name, @importer.import_source_name)
      end

      def process
        with_each_item do |item|
          summariser.counting_errors(response) do
            importer.import_item(item, response, summariser)
          end
        end
        Rails.logger.info summariser.summary

        response
      end

    private

      attr_reader :importer, :response, :summariser

      def with_each_item
        importer.each_item do |item|
          summariser.increment_import_source_count
          yield(item)
        end
        importer.all_items_imported(response, summariser) if importer.respond_to? :all_items_imported
      rescue => e
        error_message = "Error #{e.class} processing import in #{importer.class}: '#{e.message}'\n\n#{e.backtrace.join("\n")}"
        Rails.logger.error error_message
        response.errors << error_message
      end
    end
  end
end
