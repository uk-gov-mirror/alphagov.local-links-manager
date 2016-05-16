class InteractionsController < ApplicationController
  def index
    @service = Service.find_by_slug!(params[:service_slug])
    @interactions = @service.interactions
  end
end
