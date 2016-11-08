require 'local-links-manager/check_links/link_checker'

module LocalLinksManager
  module CheckLinks
    class LinkStatusUpdater
      def initialize(link_checker = LinkChecker.new)
        @link_checker = link_checker
      end

      def update
        check_all_links
        update_local_authorities_with_broken_link_count
      end

    private

      attr_reader :link_checker

      def check_all_links
        urls_for_enabled_services.each do |url|
          link_checker_response = link_checker.check_link(url)
          update_link(url, link_checker_response)
        end
      end

      def update_local_authorities_with_broken_link_count
        LocalAuthority.all.each do |local_authority|
          local_authority.update_attribute(
            :broken_link_count,
            local_authority.links.have_been_checked.currently_broken.count
          )
        end
      end

      def urls_for_enabled_services
        Link.enabled_links.distinct.pluck(:url)
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
