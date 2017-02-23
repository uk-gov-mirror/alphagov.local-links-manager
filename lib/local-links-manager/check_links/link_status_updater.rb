require 'local-links-manager/check_links/link_checker'

module LocalLinksManager
  module CheckLinks
    class LinkStatusUpdater
      def initialize(link_checker = LinkChecker.new)
        @link_checker = link_checker
      end

      def update
        urls_for_enabled_services.each do |url|
          link_checker_response = link_checker.check_link(url)
          update_link(url, link_checker_response)
          update_local_authority_broken_link_count(url)
        end
      end

    private

      attr_reader :link_checker

      def update_local_authority_broken_link_count(url)
        Link.where(url: url).each do |link|
          link.local_authority.update_broken_link_count
          link.service.update_broken_link_count
        end
      end

      def urls_for_enabled_services
        Link.enabled_links.pluck(:url).uniq
      end

      def update_link(url, link_checker_response)
        Link.where(url: url).update_all(
          status: link_checker_response[:status],
          link_last_checked: link_checker_response[:checked_at],
        )
      end
    end
  end
end
