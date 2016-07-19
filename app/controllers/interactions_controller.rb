class InteractionsController < ApplicationController
  def index
    @authority = LocalAuthorityPresenter.new(LocalAuthority.find_by_slug!(params[:local_authority_slug]))
    @service = Service.find_by_slug!(params[:service_slug])
    @interactions = presented_interactions
  end

private

  def presented_interactions
    @service.interactions.map do |interaction|
      InteractionPresenter.new(interaction, link_for_interaction(interaction))
    end
  end

  def link_for_interaction(interaction)
    presented_links.detect { |link| link.interaction == interaction }
  end

  def presented_links
    @_links ||= @authority.links.for_service(@service).map { |link| LinkPresenter.new(link) }
  end
end
