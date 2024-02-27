module LocalLinksManager
  module Export
    class LocalAuthorityLinksExporter < LocalLinksManager::Export::LinksExporter
      def links(local_authority_id, status)
        Link.enabled_links
          .where(local_authority_id:, status:)
          .joins(:local_authority, :service, :interaction)
          .select(*SELECTION)
          .order("services.lgsl_code", "interactions.lgil_code").all
      end
    end
  end
end
