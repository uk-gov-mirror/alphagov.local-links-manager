class ApiController < ApplicationController
  skip_before_action :authenticate_user!

  def link
    return render json: {}, status: :bad_request if missing_required_params_for_link?
    return render json: {}, status: :not_found if missing_objects_for_link?

    link = LocalLinksManager::LinkResolver.new(authority, service, interaction).resolve

    render json: LinkApiResponsePresenter.new(authority, link).present
  end

  def local_authority
    return render json: {}, status: :bad_request if missing_required_params_for_local_authority?
    return render json: {}, status: :not_found if missing_objects_for_local_authority?

    render json: LocalAuthorityApiResponsePresenter.new(authority).present
  end

private

  def missing_required_params_for_link?
    missing_authority_identity? || conflicting_authority_identity? || params[:lgsl].blank?
  end

  def missing_required_params_for_local_authority?
    missing_authority_identity? || conflicting_authority_identity?
  end

  def missing_authority_identity?
    params[:authority_slug].blank? && params[:local_custodian_code].blank?
  end

  def conflicting_authority_identity?
    params[:authority_slug].present? && params[:local_custodian_code].present?
  end

  def missing_objects_for_link?
    authority.nil? || service.nil?
  end

  def missing_objects_for_local_authority?
    authority.nil?
  end

  def authority
    @authority ||= if params[:authority_slug]
                     LocalAuthority.find_current_by_slug(params[:authority_slug])
                   elsif params[:local_custodian_code]
                     LocalAuthority.find_current_by_local_custodian_code(params[:local_custodian_code])
                   end
  end

  def service
    @service ||= Service.find_by(lgsl_code: params[:lgsl])
  end

  def interaction
    @interaction ||= Interaction.find_by(lgil_code: params[:lgil])
  end
end
