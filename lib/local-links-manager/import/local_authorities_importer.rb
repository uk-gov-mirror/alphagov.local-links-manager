module LocalLinksManager
  module Import
    class LocalAuthoritiesImporter
      DISTRICT = 'district'
      COUNTY = 'county'
      UNITARY = 'unitary'

      LOCAL_AUTHORITY_MAPPING = {
        "COI" => UNITARY,
        "CTY" => COUNTY,
        "DIS" => DISTRICT,
        "LBO" => UNITARY,
        "LGD" => UNITARY,
        "MTD" => UNITARY,
        "UTA" => UNITARY,
      }

      def self.import_from_mapit
        new.authorities_from_mapit
      end

      def initialize(import_comparer = ImportComparer.new("local authority"))
        @comparer = import_comparer
      end

      def authorities_from_mapit
        mapit_las = mapit_authorities

        mapit_las.each do |mapit_la|
          if mapit_la[:gss].blank? || mapit_la[:snac].blank?
            Rails.logger.warn("Found empty code for local authority: #{mapit_la[:name]}")
            next
          end

          la = create_or_update_la(mapit_la)
          @comparer.add_source_record(la.gss)
        end
        @comparer.check_missing_records(LocalAuthority.all, &:gss)
      end

    private

      def create_or_update_la(mapit_la)
        la = LocalAuthority.where(gss: mapit_la[:gss]).first_or_initialize
        verb = la.persisted? ? "Updating" : "Creating"
        Rails.logger.info("#{verb} authority '#{mapit_la[:name]}' (gss #{mapit_la[:gss]})")

        la.name = mapit_la[:name]
        la.snac = mapit_la[:snac]
        la.slug = mapit_la[:slug]
        la.tier = mapit_la[:tier]
        la.save!
        la
      end

      def mapit_authorities
        authorities = mapit_service_response.to_hash

        authorities.values.map { |authority|
          local_authority_hash(authority)
        }
      end

      def mapit_service_response
        Services.mapit.areas_for_type(local_authority_types)
      end

      def local_authority_types
        LOCAL_AUTHORITY_MAPPING.keys.join(',')
      end

      def local_authority_hash(parsed_authority)
        authority = {}
        authority[:name] = parsed_authority["name"]
        authority[:snac] = parsed_authority["codes"]["ons"]
        authority[:gss] = parsed_authority["codes"]["gss"]
        authority[:slug] = parsed_authority["codes"]["govuk_slug"]
        authority[:tier] = identify_tier(parsed_authority["type"])
        authority
      end

      def identify_tier(area_type)
        LOCAL_AUTHORITY_MAPPING[area_type]
      end
    end
  end
end
