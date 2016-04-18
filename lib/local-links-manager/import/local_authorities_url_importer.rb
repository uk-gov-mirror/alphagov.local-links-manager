require 'csv'

module LocalLinksManager
  module Import
    class LocalAuthoritiesURLImporter
      CONTACTS_LIST_URL = "http://local.direct.gov.uk/Data/local_authority_contact_details.csv"

      def self.import_urls
        new.import
      end

      def import
        csv_body = get_response(CONTACTS_LIST_URL).body

        CSV.parse(csv_body, headers: true).each do |row|
          begin
            process_row(row)
          rescue => e
            Rails.logger.error "Error #{e.class} processing row in #{self.class}\n#{e.backtrace.join("\n")}"
          end
        end
      end

    private

      def get_response(url)
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)

        if response.code != "200"
          raise "HTTP get failed [#{response.code}]: #{url}"
        end
        response
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
