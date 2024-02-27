module LocalLinksManager
  module Export
    class ServiceLinksExporter < LocalLinksManager::Export::LinksExporter
      def links(service_id, status)
        Link.joins(:service).where(services: { id: service_id }, status:)
          .joins(:local_authority, :interaction)
          .select(*SELECTION)
          .order("local_authorities.name", "interactions.lgil_code").all
      end
    end
  end
end
