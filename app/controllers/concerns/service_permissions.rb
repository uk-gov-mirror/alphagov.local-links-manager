module ServicePermissions
  def gds_editor?
    current_user.permissions.include?("GDS Editor")
  end

  def service_owner?(service)
    service.organisation_slugs.include?(current_user.organisation_slug)
  end

  def permission_for_service?(service)
    gds_editor? || service_owner?(service)
  end

  def org_name_for_current_user
    GdsApi.organisations.organisation(current_user.organisation_slug).to_hash["title"]
  rescue GdsApi::HTTPUnavailable
    current_user.organisation_slug
  end

  def redirect_unless_gds_editor
    redirect_to services_path unless gds_editor?
  end

  def forbid_unless_permission
    raise GDS::SSO::PermissionDeniedError, "You do not have permission to view this page" unless permission_for_service?(@service)
  end

  def forbid_unless_gds_editor
    raise GDS::SSO::PermissionDeniedError, "You do not have permission to view this page" unless gds_editor?
  end
end
