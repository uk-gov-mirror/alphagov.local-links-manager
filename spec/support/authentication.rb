module AuthenticationControllerHelpers
  def login_as(user)
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:user_signed_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  def login_as_department_user(organisation_slug: "random-department")
    login_as(create(:user, organisation_slug:))
  end

  def login_as_gds_editor
    login_as(create(:user, permissions: ["GDS Editor"], organisation_slug: "government-digital-service"))
  end
end
