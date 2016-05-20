class InteractionsController < ApplicationController
  def index
    @authority = LocalAuthority.find_by_slug!(params[:local_authority_slug])
    @service = Service.find_by_slug!(params[:service_slug])
    @interactions = @service.interactions
  end
end
