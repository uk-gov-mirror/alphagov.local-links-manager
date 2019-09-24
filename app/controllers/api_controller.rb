require "local-links-manager/link_resolver"

class ApiController < ApplicationController
  skip_before_action :authenticate_user!

  def link
    return render json: {}, status: 400 if missing_required_params_for_link?
    return render json: {}, status: 404 if missing_objects_for_link?

    @link = LocalLinksManager::LinkResolver.new(authority, service, interaction).resolve

    render json: LinkApiResponsePresenter.new(authority, @link).present
  end

  def local_authority
    return render json: {}, status: 400 if missing_required_params_for_local_authority?
    return render json: {}, status: 404 if missing_objects_for_local_authority?

    render json: LocalAuthorityApiResponsePresenter.new(authority).present
  end

private

  def missing_required_params_for_link?
    params[:authority_slug].blank? || params[:lgsl].blank?
  end

  def missing_required_params_for_local_authority?
    params[:authority_slug].blank?
  end

  def missing_objects_for_link?
    authority.nil? || service.nil?
  end

  def missing_objects_for_local_authority?
    authority.nil?
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
