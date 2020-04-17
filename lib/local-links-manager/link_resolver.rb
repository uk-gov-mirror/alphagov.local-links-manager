module LocalLinksManager
  class LinkResolver
    def initialize(authority, service, interaction = nil)
      @authority = authority
      @service = service
      @interaction = interaction
    end

    def resolve
      if @interaction
        link_for_interaction
      else
        fallback_link
      end
    end

  private

    def link_for_interaction
      authority = @authority
      link = authority.links.lookup_by_service_and_interaction(@service, @interaction)

      while link.nil? && can_lookup_link_from_parent(authority)
        authority = authority.parent_local_authority
        link = authority.links.lookup_by_service_and_interaction(@service, @interaction)
      end

      link
    end

    def can_lookup_link_from_parent(authority)
      return false unless authority.parent_local_authority

      @service.local_authorities.exists?(authority.parent_local_authority.id)
    end

    def fallback_link
      if service_links_ordered_by_lgil.count == 1
        service_links_ordered_by_lgil.first
      else
        link_with_lowest_lgil_but_not_providing_information_lgil
      end
    end

    def service_links_ordered_by_lgil
      @service_links_ordered_by_lgil ||= @authority.links.for_service(@service).order("interactions.lgil_code").to_a
    end

    def link_with_lowest_lgil_but_not_providing_information_lgil
      service_links_ordered_by_lgil.detect do |link|
        link.interaction.lgil_code != Interaction::PROVIDING_INFORMATION_LGIL
      end
    end
  end
end
