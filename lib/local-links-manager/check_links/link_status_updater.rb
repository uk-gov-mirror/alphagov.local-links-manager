require 'local-links-manager/check_links/link_checker'

module LocalLinksManager
  module CheckLinks
    class LinkStatusUpdater
      attr_reader :column, :table, :url_checker

      def initialize(url_checker = LinkChecker.new)
        @table = Link
        @column = :url
        @url_checker = url_checker
      end

      def update
        links_responses = url_checker.check_links(links)
        update_links(links_responses)
      end

    private

      def links
        table.joins(:service).where(services: { enabled: true }).distinct.pluck(column)
      end

      def update_links(links_responses)
        links_responses.each do |k, v|
          table.where(column => k).update_all(status: v.first, link_last_checked: v.last)
        end
      end
    end
  end
end
