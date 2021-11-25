require "csv"

module LocalLinksManager
  module Import
    class LocalCustodianCodesImporter
      LOCAL_CUSTODIAN_CODE_INDEX = 0
      AUTHORITY_HEADER_INDEX = 1

      def import_from_csv(csv_file)
        csv = CSV.read(csv_file, { headers: true, encoding: "bom|utf-8" })

        csv.each do |row|
          slug = row[AUTHORITY_HEADER_INDEX].parameterize
          code = row[LOCAL_CUSTODIAN_CODE_INDEX]
          begin
            local_authority = LocalAuthority.find_by!(slug: normalize_slug(slug))
            local_authority.update!(local_custodian_code: code)
          rescue ActiveRecord::RecordNotFound
            Rails.logger.info("Not found #{slug}, not updated")
          end
        end
      end

      def normalize_slug(slug)
        @exceptions ||= YAML.load_file("data/unmatched_slugs.yml")
        @exceptions[slug] || slug
      end
    end
  end
end
