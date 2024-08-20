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

RSpec.shared_examples "redirects non-GDS Editors to services page" do |path|
  context "as a GDS Editor" do
    before { login_as_gds_editor }

    it "shows the page" do
      get path

      expect(response).to have_http_status(:ok)
    end
  end

  context "as a department user" do
    before { login_as_department_user }

    it "does not show the page" do
      get path

      expect(response).to redirect_to(services_path)
    end
  end
end

RSpec.shared_examples "it is forbidden to non-GDS Editors" do |path|
  context "as a GDS Editor" do
    before { login_as_gds_editor }

    it "shows the page" do
      get path

      expect(response).to have_http_status(:ok)
    end
  end

  context "as a department user" do
    before { login_as_department_user }

    it "does not show the page" do
      get path

      expect(response).to have_http_status(:forbidden)
    end
  end
end

RSpec.shared_examples "it is forbidden to non-owners" do |path, owning_department|
  context "as a GDS Editor" do
    before { login_as_gds_editor }

    it "returns 200 OK" do
      get path

      expect(response).to have_http_status(:ok)
    end
  end

  context "as a department user from the owning department" do
    before { login_as_department_user(organisation_slug: owning_department) }

    it "returns 200 OK" do
      get path

      expect(response).to have_http_status(:ok)
    end
  end

  context "as a department user" do
    before { login_as_department_user }

    it "returns 403 Forbidden" do
      get path

      expect(response).to have_http_status(:forbidden)
    end
  end
end
