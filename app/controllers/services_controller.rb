class ServicesController < ApplicationController
  def index
    @services = Service.enabled.order(broken_link_count: :desc)
  end

  def show
    @service = Service.find_by(slug: params[:service_slug])

    @local_authorities = LocalAuthority.
      provides_service(@service).
      order(name: :asc)

      @links = Link.
        for_service(@service).
        with_correct_service_and_tier.
        includes(:interaction).
        enabled_links.
        order('links.local_authority_id asc, interactions.lgil_code asc').
        references(:service, :interaction).
        all.
        group_by { |link| link.local_authority_id }
  end
end
