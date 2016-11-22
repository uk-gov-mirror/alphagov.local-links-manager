class ServicesController < ApplicationController
  def index
    @services = Service.enabled.order(broken_link_count: :desc)
  end

  def show
    @service = Service.find_by(slug: params[:service_slug])

    @local_authorities = @service.local_authorities.order(name: :asc)

    @links = @service.links.includes([:service, :interaction, :local_authority]).all.group_by(&:local_authority_id)
  end
end
