require_relative 'csv_downloader'

module LocalLinksManager
  module Import
    class LocalAuthoritiesURLImporter
      CSV_URL = "http://local.direct.gov.uk/Data/local_authority_contact_details.csv"

      def self.import_urls
        new.import_records
      end

      def initialize(csv_downloader = CsvDownloader.new(CSV_URL, encoding: 'windows-1252'))
        @csv_downloader = csv_downloader
      end

      def import_records
        @csv_downloader.each_row do |row|
          begin
            process_row(row)
          rescue => e
            Rails.logger.error "Error #{e.class} processing row in #{self.class}\n#{e.backtrace.join("\n")}"
          end
        end
      end

      def self.alert_empty_urls(service_desc)
        las_with_empty_urls = LocalAuthority.where(homepage_url: [nil, ''])

        if las_with_empty_urls.any?
          alert_missing_urls(service_desc, las_with_empty_urls)
        else
          confirm_no_missing_urls(service_desc)
        end
      end

    private

      def self.alert_missing_urls(service_desc, local_authorities)
        Services.icinga_check(service_desc, false, local_authorities.map(&:gss).join("\n"))
      end

      def self.confirm_no_missing_urls(service_desc)
        Services.icinga_check(service_desc, true, "Success")
      end

      def process_row(row)
        return if row['SNAC Code'].blank?
        authority = LocalAuthority.find_by(snac: row['SNAC Code'])
        unless authority
          Rails.logger.warn "#{self.class}: failed to find LocalAuthority with SNAC #{row['SNAC Code']}"
          return
        end
        authority.homepage_url = parse_url(row['Home page URL'])
        authority.save!
      end

      def parse_url(url)
        if url.blank? || url.start_with?("http://") || url.start_with?("https://")
          url
        else
          "http://" + url
        end
      end
    end
  end
end
