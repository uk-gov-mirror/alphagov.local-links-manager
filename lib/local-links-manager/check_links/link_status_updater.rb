module LocalLinksManager
  module CheckLinks
    class LinkStatusUpdater
      def call(batch_report)
        batch_report.links.each do |link_report|
          update_link(link_report)
          update_local_authority_broken_link_count(link_report.uri)
        end
      end

    private

      def update_local_authority_broken_link_count(url)
        Link.where(url: url).each do |link|
          link.local_authority.update_broken_link_count
          link.service.update_broken_link_count
        end
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
    end
  end
end
