require_relative "import_comparer"
require_relative "processor"
require_relative "error_message_formatter"
require_relative "errors"
require Rails.root.join("app/models/tier")

module LocalLinksManager
  module Import
    class LocalAuthoritiesImporter
      DISTRICT = Tier.district
      COUNTY = Tier.county
      UNITARY = Tier.unitary

      def self.import_from_csv(path_to_csv)
        @csv_data = nil # reset in case called multiple times with different files
        new.authorities_from_csv(path_to_csv)
      end

      def initialize(import_comparer = ImportComparer.new)
        @comparer = import_comparer
      end

      def authorities_from_csv(path_to_csv)
        @path_to_csv = path_to_csv
        Processor.new(self).process
      end

      def each_item(&block)
        csv_authorities.each(&block)
      end

      def import_item(item, _response, summariser)
        la = create_or_update_la(item, summariser)
        @comparer.add_source_record(la.slug)
      end

      def all_items_imported(response, _summariser)
        orphaned = connect_parents(csv_authorities)
        response.errors << error_message_for_orphaned(orphaned) unless orphaned.empty?

        missing = @comparer.check_missing_records(LocalAuthority.all, &:slug)
        response.errors << error_message_for_missing(missing) unless missing.empty?
      end

      def import_name
        "LocalAuthorities Import"
      end

      def import_source_name
        "Objects from CSV file"
      end

    private

      def create_or_update_la(local_authority, summariser)
        raise Errors::MissingIdentifierError, "Found empty code for local authority: #{local_authority[:name]}" if local_authority[:gss].blank? || local_authority[:snac].blank?

        la = LocalAuthority.where(gss: local_authority[:gss]).first_or_initialize
        existing_record = la.persisted?
        verb = existing_record ? "Updating" : "Creating"
        Rails.logger.info("#{verb} authority '#{local_authority[:name]}' (gss #{local_authority[:gss]})")

        la.name = local_authority[:name]
        la.snac = local_authority[:snac]
        la.slug = local_authority[:slug]
        la.tier_id = local_authority[:tier_id]
        la.country_name = local_authority[:country_name]
        la.save!
        if existing_record
          summariser.increment_updated_record_count
        else
          summariser.increment_created_record_count
        end
        la
      end

      def csv_authorities
        @csv_authorities ||=
          CSV.read(@path_to_csv)
            .drop(1) # remove 'headings' row
            .map { |row| local_authority_hash(*row) }
      end

      def local_authority_hash(id, gss, snac, local_custodian_code, tier_id, parent_local_authority_id, slug, country_name, homepage_url, name)
        {
          name:,
          snac:,
          gss:,
          slug:,
          local_custodian_code:,
          homepage_url:,
          tier_id: tier_id.to_i,
          country_name:,
          id: id.to_i,
          parent_local_authority_id: parent_local_authority_id.nil? ? nil : parent_local_authority_id.to_i,
        }
      end

      def connect_parents(las)
        orphaned = []
        child_las(las).each do |child_la|
          parent_la = find_parent_la(las, child_la)
          orphaned << child_la[:slug] && next if parent_la.nil?

          parent = LocalAuthority.find_by(slug: parent_la[:slug])
          orphaned << child_la[:slug] && next if parent.nil?

          update_child_with_parent(child_la, parent)
        end
        orphaned
      end

      def update_child_with_parent(child_la, parent)
        child = LocalAuthority.find_by(slug: child_la[:slug])
        child.parent_local_authority = parent
        child.save!
      end

      def child_las(las)
        las.select { |la| la[:parent_local_authority_id] }
      end

      def find_parent_la(las, child_la)
        las.detect do |la|
          la[:id] == child_la[:parent_local_authority_id]
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
