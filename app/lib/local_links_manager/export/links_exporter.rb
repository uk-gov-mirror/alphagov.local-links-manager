require "csv"

module LocalLinksManager
  module Export
    class LinksExporter
      SELECTION = [
        "local_authorities.name",
        :snac,
        :gss,
        "services.label as service_label",
        "interactions.label as interaction_label",
        "links.status as status",
        :lgsl_code,
        :lgil_code,
        :url,
        :enabled,
      ].freeze
      COMMON_HEADINGS = [
        "Authority Name",
        "SNAC",
        "GSS",
        "Description",
        "LGSL",
        "LGIL",
        "URL",
        "Supported by GOV.UK",
      ].freeze
      EXTRA_HEADINGS = ["Status", "New URL"].freeze

      def self.export_links
        path = Rails.root.join("public/data/links_to_services_provided_by_local_authorities.csv")

        File.open(path, "w") do |file|
          new.export(file)
        end
      end

      def export(io)
        output = CSV.generate do |csv|
          csv << COMMON_HEADINGS
          records.each do |record|
            csv << format(record)
          end
        end
        io.write(output)
      end

      def export_links(local_authority_id, params)
        statuses = params.slice("ok", "broken", "caution", "missing", "pending").keys
        CSV.generate do |csv|
          csv << COMMON_HEADINGS + EXTRA_HEADINGS
          statuses.each do |status|
            links(local_authority_id, status).each do |link|
              csv << format(link).push(link.status)
            end
          end
        end
      end

      def records
        Link.with_url.joins(:local_authority, :service, :interaction)
          .select(*SELECTION)
          .order("local_authorities.name", "services.lgsl_code", "interactions.lgil_code").all
      end

    private

      def links(local_authority_id, status)
        Link.enabled_links.public_send(status)
          .where(local_authority_id:)
          .joins(:local_authority, :service, :interaction)
          .select(*SELECTION)
          .order("services.lgsl_code", "interactions.lgil_code").all
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
          record.enabled,
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
