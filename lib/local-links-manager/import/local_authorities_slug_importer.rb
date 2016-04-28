module LocalLinksManager
  module Import
    class LocalAuthoritiesSlugImporter
      AUTHORITIES_URL = "https://raw.githubusercontent.com/alphagov/frontend/master/lib/data/authorities.json"

      def self.import_slugs
        new.import
      end

      def import
        all_authorities = LocalAuthority.all
        all_authorities.each do |authority|
          slug = gss_to_slug[authority.gss]
          if slug
            Rails.logger.info "Found slug '#{slug}' for GSS code: '#{authority.gss}'"
            authority.slug = slug
            authority.save
          else
            Rails.logger.warn "Could not find slug for GSS code: '#{authority.gss}'"
          end
        end
      end

    private

      def create_gss_to_slug_lookup
        authorities.each_with_object({}) do |(slug, codes), lookup|
          lookup[codes["gss"]] = slug
        end
      end

      def find_slug_from_gss(gss)
        gss_to_slug[gss]
      end

      def gss_to_slug
        @gss_to_slug ||= create_gss_to_slug_lookup
      end

      def authorities
        @authorities ||= get_json(AUTHORITIES_URL)
      end

      def get_json(url)
        raw_response = get_response(url)
        JSON.parse(raw_response.body)
      end

      def get_response(url)
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)

        if response.code != "200"
          raise "HTTP get failed [#{response.code}]: #{url}"
        end
        response
      end
    end
  end
end
