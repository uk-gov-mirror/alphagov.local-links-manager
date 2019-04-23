require "csv"

module LocalLinksManager
  module Import
    class Links
      def initialize(local_authority)
        @local_authority = local_authority
      end

      def import_links(csv_string)
        updated = 0
        CSV.parse(csv_string, headers: true) do |row|
          next if row["New URL"].blank?

          service = Service.find_by(lgsl_code: row["LGSL"])
          interaction = Interaction.find_by(lgil_code: row["LGIL"])

          next unless service && interaction

          link = Link.retrieve_or_build(
            local_authority_slug: local_authority.slug,
            service_slug: service.slug,
            interaction_slug: interaction.slug,
          )

          link.update!(url: row["New URL"])

          updated += 1
        end

        updated
      end

    private

      attr_reader :local_authority
    end
  end
end
