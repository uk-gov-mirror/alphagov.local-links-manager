module LocalLinksManager
  module CheckLinks
    class LinkChecker
      TIMEOUT = 5
      REDIRECT_LIMIT = 10

      def check_link(link)
        {
          status: fetch_status(link),
          checked_at: Time.zone.now,
        }
      end

    private

      def fetch_status(link)
        begin
          response = connection.get(URI.parse(link)) do |request|
            request.options[:timeout] = TIMEOUT
            request.options[:open_timeout] = TIMEOUT
          end
          response.status.to_s
        rescue Faraday::ConnectionFailed
          "Connection failed"
        rescue Faraday::TimeoutError
          "Timeout Error"
        rescue Faraday::SSLError
          "SSL Error"
        rescue FaradayMiddleware::RedirectLimitReached
          "Too many redirects"
        rescue URI::InvalidURIError
          "Invalid URI"
        rescue => e
          e.class.to_s
        end
      end

      def connection
        @connection ||= Faraday.new(headers: { accept_encoding: 'none' }) do |faraday|
          faraday.use FaradayMiddleware::FollowRedirects, limit: REDIRECT_LIMIT
          faraday.adapter Faraday.default_adapter
        end
      end
    end
  end
end
