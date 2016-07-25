class ApiController < ApplicationController
  skip_before_action :require_signin_permission!
  before_action :load_authority, :load_service

  PROVIDING_INFORMATION_LGIL = 8

  def link
    render json: {}, status: 400 and return unless params[:authority_slug] && params[:lgsl]
    render json: {}, status: 404 and return unless @authority && @service

    if params[:lgil]
      load_service_interaction
      render json: {}, status: 404 and return unless @service_interaction
      return_link_for_lgil
    else
      return_fallback_link
    end
  end

private

  def load_authority
    @authority = LocalAuthority.find_by(slug: params[:authority_slug])
  end

  def load_service
    @service = Service.find_by(lgsl_code: params[:lgsl])
  end

  def load_service_interaction
    @service_interaction = ServiceInteraction.find_by(service: @service, interaction: interaction)
  end

  def interaction
    Interaction.find_by(lgil_code: params[:lgil])
  end

  def return_link_for_lgil
    @link = @authority.links.find_by_lgsl_and_lgil(params[:lgsl], params[:lgil])
    render json: local_interaction_response
  end

  def return_fallback_link
    if service_links_ordered_by_lgil.count == 1
      @link = service_links_ordered_by_lgil.first
    else
      @link = link_with_lowest_lgil_but_not_providing_information_lgil
    end

    render json: local_interaction_response
  end

  def service_links_ordered_by_lgil
    @_links ||= @authority.links.for_service(@service).order("interactions.lgil_code").to_a
  end

  def link_with_lowest_lgil_but_not_providing_information_lgil
    service_links_ordered_by_lgil.detect do |link|
      link.interaction.lgil_code != PROVIDING_INFORMATION_LGIL
    end
  end

  def local_interaction_response
    if @link
      local_authority_details.merge(link_details)
    else
      local_authority_details
    end
  end

  def local_authority_details
    {
      "local_authority" => {
        "name" => @authority.name,
        "snac" => @authority.snac,
        "tier" => @authority.tier,
        "homepage_url" => @authority.homepage_url
      }
    }
  end

  def link_details
    {
      "local_interaction" => {
        "lgsl_code" => @link.service.lgsl_code,
        "lgil_code" => @link.interaction.lgil_code,
        "url" => @link.url
      }
    }
  end
end
