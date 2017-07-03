require 'csv'

module LocalLinksManager
  module Export
    class BadLinksUrlAndStatusExporter
      HEADINGS = %w(url link_errors link_warnings).freeze
      def self.local_authority_bad_homepage_url_and_status_csv
        CSV.generate do |csv|
          csv << HEADINGS
          LocalAuthority.where.not(status: "ok").pluck(:homepage_url, :link_errors, :link_warnings).each do |la|
            csv << [la[0], la[1].join(','), la[2].join(',')]
          end
        end
      end

      def self.bad_links_url_and_status_csv
        CSV.generate do |csv|
          csv << HEADINGS
          Link.enabled_links.where.not(status: "ok").group_by(&:url).each do |links|
            link = links.last.pluck(:url, :link_errors, :link_warnings).first
            csv << [link[0], link[1].join(','), link[2].join(',')]
          end
        end
      end
    end
  end
end
