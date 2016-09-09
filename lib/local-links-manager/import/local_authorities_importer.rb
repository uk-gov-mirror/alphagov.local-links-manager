require_relative 'import_comparer'
require_relative 'response'
require_relative 'error_message_formatter'
require_relative 'errors'

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

      def initialize(import_comparer = ImportComparer.new)
        @comparer = import_comparer

        @mapit_objects_count = 0
        @missing_record_count = 0
        @missing_id_count = 0
        @invalid_record_count = 0
        @created_record_count = 0
        @updated_record_count = 0
      end

      def authorities_from_mapit
        @response = Response.new

        mapit_las = mapit_authorities

        mapit_las.each do |mapit_la|
          @mapit_objects_count += 1
          counting_errors do
            la = create_or_update_la(mapit_la)
            @comparer.add_source_record(la.slug)
          end
        end

        orphaned = connect_parents(mapit_las)
        @response.errors << error_message_for_orphaned(orphaned) unless orphaned.empty?

        missing = @comparer.check_missing_records(LocalAuthority.all, &:slug)
        @response.errors << error_message_for_missing(missing) unless missing.empty?

        Rails.logger.info import_summary

        @response
      end

      def self.local_authority_types
        LOCAL_AUTHORITY_MAPPING.keys.join(',')
      end

    private

      def import_summary
        "LocalAuthorities Import complete\n"\
        "Objects from Mapit: #{@mapit_objects_count}\n"\
        "Created records: #{@updated_record_count}\n"\
        "Updated records: #{@updated_record_count}\n"\
        "Import errors with missing Identifier: #{@missing_id_count}\n"\
        "Import errors with invalid values for record: #{@invalid_record_count}\n"
      end

      def create_or_update_la(mapit_la)
        raise MissingIdentifierError, "Found empty code for local authority: #{mapit_la[:name]}" if mapit_la[:gss].blank? || mapit_la[:snac].blank?
        la = LocalAuthority.where(gss: mapit_la[:gss]).first_or_initialize
        existing_record = la.persisted?
        verb = existing_record ? "Updating" : "Creating"
        Rails.logger.info("#{verb} authority '#{mapit_la[:name]}' (gss #{mapit_la[:gss]})")

        la.name = mapit_la[:name]
        la.snac = mapit_la[:snac]
        la.slug = mapit_la[:slug]
        la.tier = mapit_la[:tier]
        la.save!
        if existing_record
          @updated_record_count += 1
        else
          @created_record_count += 1
        end
        la
      end

      def counting_errors(&block)
        block.call
      rescue MissingIdentifierError => e
        @missing_id_count += 1
        Rails.logger.error e.message
        @response.errors << e.message
      rescue ActiveRecord::RecordInvalid => e
        @invalid_record_count += 1
        Rails.logger.error e.message
        @response.errors << e.message
      end

      def mapit_authorities
        authorities = mapit_service_response.to_hash

        authorities.values.map { |authority|
          local_authority_hash(authority)
        }
      end

      def mapit_service_response
        Services.mapit.areas_for_type(self.class.local_authority_types)
      end

      def local_authority_hash(parsed_authority)
        authority = {}
        authority[:name] = parsed_authority["name"]
        authority[:snac] = parsed_authority["codes"]["ons"]
        authority[:gss] = parsed_authority["codes"]["gss"]
        authority[:slug] = parsed_authority["codes"]["govuk_slug"]
        authority[:tier] = identify_tier(parsed_authority["type"])
        authority[:mapit_id] = parsed_authority["id"]
        authority[:parent_mapit_id] = parsed_authority["parent_area"]
        authority
      end

      def identify_tier(area_type)
        LOCAL_AUTHORITY_MAPPING[area_type]
      end

      def connect_parents(mapit_las)
        orphaned = []
        child_mapit_las(mapit_las).each do |child_mapit_la|
          parent_mapit_la = find_parent_mapit_la(mapit_las, child_mapit_la)
          orphaned << child_mapit_la[:slug] && next if parent_mapit_la.nil?

          parent = LocalAuthority.find_by(slug: parent_mapit_la[:slug])
          orphaned << child_mapit_la[:slug] && next if parent.nil?

          update_child_with_parent(child_mapit_la, parent)
        end
        orphaned
      end

      def update_child_with_parent(child_mapit_la, parent)
        child = LocalAuthority.find_by(slug: child_mapit_la[:slug])
        child.parent_local_authority = parent
        child.save!
      end

      def child_mapit_las(mapit_las)
        mapit_las.select { |la| la[:parent_mapit_id] }
      end

      def find_parent_mapit_la(mapit_las, child_mapit_la)
        mapit_las.detect do |la|
          la[:mapit_id] == child_mapit_la[:parent_mapit_id]
        end
      end

      def error_message_for_orphaned(orphaned)
        ErrorMessageFormatter.new("LocalAuthority", "orphaned.", orphaned).message
      end

      def error_message_for_missing(missing)
        ErrorMessageFormatter.new("LocalAuthority", "no longer in the import source.", missing).message
      end
    end
  end
end
