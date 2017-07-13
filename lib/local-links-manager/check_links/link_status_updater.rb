module LocalLinksManager
  module CheckLinks
    class LinkStatusUpdater
      def call(batch_report)
        batch_report.links.each do |link_report|
          update_link(link_report)
          register_authority_and_service_for_update(link_report.uri)
        end

        update_broken_link_counts
      end

    private

      def register_authority_and_service_for_update(url)
        Link.where(url: url).each do |link|
          local_authority_ids.add(link.local_authority.id)
          service_ids.add(link.service.id)
        end
      end

      def update_broken_link_counts
        LocalAuthority.where(id: local_authority_ids.to_a)
          .each(&:update_broken_link_count)

        Service.where(id: service_ids.to_a)
          .each(&:update_broken_link_count)
      end

      def update_link(link_report)
        fields = link_report_fields(link_report)

        Link
          .where(url: link_report.uri)
          .last_checked_before(link_report.checked)
          .update_all(fields)

        LocalAuthority
          .where(homepage_url: link_report.uri)
          .link_last_checked_before(link_report.checked)
          .update_all(fields)
      end

      def link_report_fields(link_report)
        {
          status: link_report.status,
          link_errors: link_report.errors,
          link_warnings: link_report.warnings,
          link_last_checked: link_report.checked,
          problem_summary: link_report.problem_summary,
          suggested_fix: link_report.suggested_fix,
        }
      end

      def local_authority_ids
        @local_authority_ids ||= Set.new
      end

      def service_ids
        @service_ids ||= Set.new
      end
    end
  end
end
