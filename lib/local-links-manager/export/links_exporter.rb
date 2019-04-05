require 'csv'

module LocalLinksManager
  module Export
    class LinksExporter
      HEADINGS = ["Authority Name", "SNAC", "GSS", "Description", "LGSL", "LGIL", "URL"].freeze
      ALL_LINKS_HEADINGS = ["Supported by GOV.UK"].freeze
      BROKEN_LINKS_HEADINGS = ["New URL"].freeze

      def self.export_links
        path = Rails.root.join("public", "data", 'links_to_services_provided_by_local_authorities.csv')

        File.open(path, 'w') do |file|
          new.export(file)
        end
      end

      def export(io)
        output = CSV.generate do |csv|
          csv << HEADINGS + ALL_LINKS_HEADINGS
          records.each do |record|
            csv << format(record).push(record.enabled)
          end
        end
        io.write(output)
      end

      def export_broken_links(local_authority_id)
        CSV.generate do |csv|
          csv << HEADINGS + BROKEN_LINKS_HEADINGS
          broken_links(local_authority_id).each do |link|
            csv << format(link)
          end
        end
      end

      def records
        Link.with_url.joins(:local_authority, :service, :interaction)
          .select(
            "local_authorities.name",
            :snac,
            :gss,
            "services.label as service_label",
            "interactions.label as interaction_label",
            :lgsl_code,
            :lgil_code,
            :url,
            :enabled
          ).order("local_authorities.name", "services.lgsl_code", "interactions.lgil_code").all
      end

    private

      def broken_links(local_authority_id)
        Link.enabled_links.broken
          .where(local_authority_id: local_authority_id)
          .joins(:local_authority, :service, :interaction)
          .select(
            "local_authorities.name",
            :snac,
            :gss,
            "services.label as service_label",
            "interactions.label as interaction_label",
            :lgsl_code,
            :lgil_code,
            :url,
          ).order("services.lgsl_code", "interactions.lgil_code").all
      end

      def format(record)
        [
          record.name,
          snac(record),
          record.gss,
          description(record),
          record.lgsl_code,
          record.lgil_code,
          record.url,
        ]
      end

      def description(record)
        "#{record.service_label}: #{record.interaction_label}"
      end

      def snac(record)
        record.snac unless record.snac == record.gss
      end
    end
  end
end
