require "gds_api/link_checker_api"

module LocalLinksManager
  module CheckLinks
    class LinkStatusRequester
      delegate :url_helpers, to: "Rails.application.routes"

      def call
        ServiceInteraction.includes(:service)
          .where(services: { enabled: true })
          .each do |service|
          check_urls service.links.order(analytics: :asc).map(&:url).uniq
        end

        check_urls homepage_urls
      end

      def check_authority_urls(authority_slug)
        check_urls urls_for_authority(authority_slug).uniq
      end

    private

      def urls_for_authority(authority_slug)
        local_authority = LocalAuthority.find_by(slug: authority_slug)
        local_authority.links.map(&:url) << local_authority.homepage_url
      end

      def homepage_urls
        LocalAuthority.all.map(&:homepage_url)
      end

      def check_urls(urls)
        link_checker_api.create_batch(
          urls,
          webhook_uri: webhook_uri,
          webhook_secret_token: webhook_secret_token
        )
      end

      def webhook_uri
        Plek.find("local-links-manager") + url_helpers.link_checker_webhook_path
      end

      def webhook_secret_token
        Rails.application.secrets.link_checker_api_secret_token
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
