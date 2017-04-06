module LocalLinksManager
  module CheckLinks
    class LinkStatusUpdater

      def call(payload)
        payload[:links].each do |check|
          update_link(check)
          update_local_authority_broken_link_count(check[:uri])
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

      def update_link(check)
        Link.where(url: check[:uri]).update_all(
          status: check[:status],
          link_errors: check[:errors],
          link_warnings: check[:warnings],
          link_last_checked: check[:checked]
        )
        LocalAuthority.where(homepage_url: check[:uri]).update_all(
          status: check[:status],
          link_errors: check[:errors],
          link_warnings: check[:warnings],
          link_last_checked: check[:checked]
        )
      end
    end

  end
end
