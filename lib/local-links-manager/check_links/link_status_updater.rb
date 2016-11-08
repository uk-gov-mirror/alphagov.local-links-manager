require 'local-links-manager/check_links/link_checker'

module LocalLinksManager
  module CheckLinks
    class LinkStatusUpdater
      attr_reader :url_checker

      def initialize(url_checker = LinkChecker.new)
        @url_checker = url_checker
      end

      def update
        links.each do |url|
          response = url_checker.check_link(url)
          update_link(url, response)
        end
      end

    private

      def links
        Link.enabled_links.distinct.pluck(:url)
      end

      def update_link(url, link_response)
        Link.where(url: url).update_all(
          status: link_response[:status],
          link_last_checked: link_response[:checked_at],
        )
      end
    end
  end
end
