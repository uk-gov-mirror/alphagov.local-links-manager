class ServicesController < ApplicationController
  def index
    @services = Service.enabled.order(broken_link_count: :desc)
    raise RuntimeError.new('Missing Data') if @services.empty?
  end

  def show
    @service = Service.find_by!(slug: params[:service_slug])
    @local_authorities = @service.local_authorities.order(name: :asc)
    @link_count = links_for_service.count
    @link_filter = params[:filter]
    @links = links_for_service.group_by(&:local_authority_id)
  end

private

  def links_for_service
    @_links_for_service ||= filtered_links
      .includes([:service, :interaction, :local_authority])
      .all
  end

  def filtered_links
    links = @service.links

    case params[:filter]
    when 'broken_links'
      links.currently_broken
    when 'good_links'
      links.good_links
    else
      links
    end
  end
end
