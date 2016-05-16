class ServicesController < ApplicationController
  def index
    @authority = LocalAuthority.find_by_slug!(params[:local_authority_slug])
    @services = Service.all
  end
end
