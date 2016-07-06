require 'local-links-manager/check_links/link_checker'

module LocalLinksManager
  module CheckLinks
    class HomepageStatusUpdater
      attr_reader :column, :table, :url_checker

      def initialize(url_checker = LinkChecker.new)
        @table = LocalAuthority
        @column = :homepage_url
        @url_checker = url_checker
      end

      def update
        links.each do |link|
          link_response = url_checker.check_link(link)
          update_link(link, link_response)
        end
      end

    private

      def links
        table.distinct.pluck(column)
      end

      def update_link(link, link_response)
        table.where(column => link).update_all(
          status: link_response[:status],
          link_last_checked: link_response[:checked_at],
        )
      end
    end
  end
end
