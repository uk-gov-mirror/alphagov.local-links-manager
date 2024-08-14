module ServicePermissions
  def gds_editor?
    current_user.permissions.include?("GDS Editor")
  end
end
