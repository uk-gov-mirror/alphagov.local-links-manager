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
      @authority.links.find_by_service_and_interaction(@service, @interaction)
    end

    def fallback_link
      if service_links_ordered_by_lgil.count == 1
        service_links_ordered_by_lgil.first
      else
        link_with_lowest_lgil_but_not_providing_information_lgil
      end
    end

    def service_links_ordered_by_lgil
      @_links ||= @authority.links.for_service(@service).order("interactions.lgil_code").to_a
    end

    def link_with_lowest_lgil_but_not_providing_information_lgil
      service_links_ordered_by_lgil.detect do |link|
        link.interaction.lgil_code != Interaction::PROVIDING_INFORMATION_LGIL
      end
    end
  end
end
