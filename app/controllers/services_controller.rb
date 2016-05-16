class ServicesController < ApplicationController
  def index
    @authority = LocalAuthority.find_by_slug!(params[:local_authority_slug])
    @services = @authority.provided_services
  end
end
