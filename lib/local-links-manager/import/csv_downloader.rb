require 'csv'

module LocalLinksManager
  module Import
    class CsvDownloader
      class Error < RuntimeError; end
      class DownloadError < Error; end
      class MalformedCSVError < Error; end

      def initialize(csv_url, header_conversions: {}, encoding: 'UTF-8')
        @csv_url = csv_url
        @header_conversions = header_conversions
        @encoding = encoding
      end

      def each_row(&block)
        download do |csv|
          csv.each(&block)
        end
      end

      def download
        downloaded_csv do |data|
          yield(CSV.parse(
            data,
              headers: true,
              header_converters: field_name_converter
            ))
        end
      rescue CSV::MalformedCSVError => e
        raise MalformedCSVError, "Error #{e.class} parsing CSV in #{self.class}"
      end

    private

      def downloaded_csv
        Tempfile.create(['local_links_manager_import', @csv_url.gsub(/[^0-9A-z.\-]+/, '_'), 'csv']) do |temp_file|
          temp_file.set_encoding('ascii-8bit')

          response = Net::HTTP.get_response(URI.parse(@csv_url))

          unless response.code_type == Net::HTTPOK
            raise DownloadError, "Error downloading CSV in #{self.class}"
          end

          temp_file.write(response.body)

          temp_file.rewind
          temp_file.set_encoding(@encoding, 'UTF-8')
          yield temp_file
        end
      end

      def field_name_converter
        lambda do |field|
          @header_conversions.key?(field) ? @header_conversions[field] : field
        end
      end
    end
  end
end
