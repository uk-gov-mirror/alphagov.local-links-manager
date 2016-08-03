require 'local-links-manager/link_resolver'

class ApiController < ApplicationController
  skip_before_action :require_signin_permission!

  def link
    return render json: {}, status: 400 if missing_required_params?
    return render json: {}, status: 404 if missing_objects?

    @link = LocalLinksManager::LinkResolver.new(authority, service, interaction).resolve

    render json: LinkApiResponsePresenter.new(authority, @link).present
  end

private

  def missing_required_params?
    params[:authority_slug].blank? || params[:lgsl].blank?
  end

  def missing_objects?
    authority.nil? || service.nil?
  end

  def authority
    @authority ||= LocalAuthority.find_by(slug: params[:authority_slug])
  end

  def service
    @service ||= Service.find_by(lgsl_code: params[:lgsl])
  end

  def interaction
    @interaction ||= Interaction.find_by(lgil_code: params[:lgil])
  end
end
