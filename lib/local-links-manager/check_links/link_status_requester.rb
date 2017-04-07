require "gds_api/link_checker_api"

module LocalLinksManager
  module CheckLinks
    class LinkStatusRequester
      delegate :url_helpers, to: "Rails.application.routes"

      def call
        LocalAuthority.all.each do |local_authority|
          link_checker_api.create_batch(
            urls_for_local_authority(local_authority),
            webhook_uri: webhook_uri
          )
        end
      end

    private

      def webhook_uri
        Plek.find("local-links-manager") + url_helpers.link_checker_webhook_path
      end

      def urls_for_local_authority(local_authority)
        (local_authority.provided_service_links.map(&:url) +
          [local_authority.homepage_url]).uniq
      end

      def link_checker_api
        @link_checker_api ||= GdsApi::LinkCheckerApi.new(link_checker_api_url)
      end

      def link_checker_api_url
        Plek.find("link-checker-api")
      end
    end
  end
end
