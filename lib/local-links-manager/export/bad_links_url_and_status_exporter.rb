require "csv"

module LocalLinksManager
  module Export
    class BadLinksUrlAndStatusExporter
      HEADINGS = %w(url status).freeze

      def self.local_authority_bad_homepage_url_and_status_csv
        CSV.generate do |csv|
          csv << HEADINGS
          LocalAuthority.where(status: "broken").distinct.pluck(:homepage_url, :problem_summary).each do |row|
            csv << row
          end
        end
      end

      def self.bad_links_url_and_status_csv
        CSV.generate do |csv|
          csv << HEADINGS
          Link.enabled_links.currently_broken.distinct.pluck(:url, :problem_summary).each do |row|
            csv << row
          end
        end
      end
    end
  end
end
