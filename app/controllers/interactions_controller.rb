class InteractionsController < ApplicationController
  def index
    @authority = LocalAuthority.find_by_slug!(params[:local_authority_slug])
    @service = Service.find_by_slug!(params[:service_slug])
    @interactions = @service.interactions
    local_authority_links_for_service = @authority.links.for_service(@service)
    @links = local_authority_links_for_service.map { |link| [link.interaction, link.url] }.to_h
  end
end
