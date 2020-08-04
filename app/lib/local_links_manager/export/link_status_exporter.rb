require "csv"

module LocalLinksManager
  module Export
    class LinkStatusExporter
      HEADINGS = %w[problem_summary count status].freeze

      def self.homepage_links_status_csv
        CSV.generate do |csv|
          csv << HEADINGS
          LocalAuthority.group(:problem_summary, :status).count.each do |(problem_summary, status), count|
            csv << [problem_summary || "nil", count, status || "nil"]
          end
        end
      end

      def self.links_status_csv
        CSV.generate do |csv|
          csv << HEADINGS
          Link.with_url.enabled_links.group(:problem_summary, :status).count.each do |(problem_summary, status), count|
            csv << [problem_summary || "nil", count, status || "nil"]
          end
        end
      end
    end
  end
end
