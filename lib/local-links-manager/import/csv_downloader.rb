require 'csv'

class CsvDownloader
  class Error < RuntimeError; end
  class DownloadError < Error; end
  class MalformedCSVError < Error; end

  def initialize(csv_url, header_conversions = {})
    @csv_url = csv_url
    @header_conversions = header_conversions
  end

  def download
    CSV.parse(downloaded_csv,
              headers: true,
              header_converters: field_name_converter)

  rescue CSV::MalformedCSVError => e
    raise MalformedCSVError, "Error #{e.class} parsing CSV in #{self.class}"
  end

private

  def downloaded_csv
    response = Net::HTTP.get_response(URI.parse(@csv_url))

    unless response.code_type == Net::HTTPOK
      raise DownloadError, "Error downloading CSV in #{self.class}"
    end

    response.body
  end

  def field_name_converter
    lambda do |field|
      @header_conversions.key?(field) ? @header_conversions[field] : field
    end
  end
end
