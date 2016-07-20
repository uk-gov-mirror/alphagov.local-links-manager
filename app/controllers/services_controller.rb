class ServicesController < ApplicationController
  def index
    @authority = LocalAuthorityPresenter.new(LocalAuthority.find_by_slug!(params[:local_authority_slug]))
    @services = @authority.provided_services.order(lgsl_code: :asc)
  end
end
