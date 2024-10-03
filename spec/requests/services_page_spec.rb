RSpec.describe "Services page" do
  let(:owning_department) { "department-of-aardvarks" }
  let!(:service) { create(:service, label: "Aardvark Wardens", organisation_slugs: [owning_department]) }

  describe "GET /services/:service_slug" do
    it_behaves_like "it is forbidden to non-owners", "/services/aardvark-wardens", "department-of-aardvarks"
  end

  describe "GET /services/:service_slug/download_links_form" do
    it_behaves_like "it is forbidden to non-owners", "/services/aardvark-wardens/download_links_form", "department-of-aardvarks"
  end

  describe "GET /services/:service_slug/upload_links_form" do
    it_behaves_like "it is forbidden to non-owners", "/services/aardvark-wardens/upload_links_form", "department-of-aardvarks"
  end

  describe "POST /services/:service_slug/download_links_csv" do
    let(:exported_data) { "some_data" }

    before do
      allow_any_instance_of(LocalLinksManager::Export::ServiceLinksExporter).to receive(:export_links).and_return(exported_data)
    end

    before { login_as_gds_editor }

    context "GET #index" do
      it "returns http success for services index page" do
        get "/services"
        expect(response).to have_http_status(200)
      end
    end

    context "Get #show" do
      it "returns http success" do
        get "/services/aardvark-wardens"
        expect(response).to have_http_status(200)
      end
    end

    context "GET #download_links_form and POST #download_links_csv" do
      let(:exported_data) { "some_data" }

      before do
        allow_any_instance_of(LocalLinksManager::Export::ServiceLinksExporter).to receive(:export_links).and_return(exported_data)
      end

      it "returns a success response" do
        create(:service)
        get "/services/aardvark-wardens/download_links_form"
        expect(response).to be_successful

        post "/services/aardvark-wardens/download_links_csv"
        expect(response).to be_successful
      end
    end

    context "as a department user from the owning department" do
      before { login_as_department_user(organisation_slug: owning_department) }

      it "returns 200 OK" do
        post "/services/aardvark-wardens/download_links_csv"

        expect(response).to have_http_status(:ok)
      end
    end

    context "as a department user" do
      before { login_as_department_user }

      it "returns 403 Forbidden" do
        post "/services/aardvark-wardens/download_links_csv"

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /services/:service_slug/upload_links_csv" do
    context "as a GDS Editor" do
      before { login_as_gds_editor }

      it "returns a success response" do
        get "/services/aardvark-wardens/upload_links_form"
        expect(response).to be_successful
      end

      it "returns 302 Found" do
        post "/services/aardvark-wardens/upload_links_csv"
        expect(response).to have_http_status(:found)
      end
    end

    context "as a department user from the owning department" do
      before { login_as_department_user(organisation_slug: owning_department) }

      it "returns 302 Found" do
        post "/services/aardvark-wardens/upload_links_csv"

        expect(response).to have_http_status(:found)
      end
    end

    context "as a department user" do
      before { login_as_department_user }

      it "returns 403 Forbidden" do
        post "/services/aardvark-wardens/upload_links_csv"

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /services/:service_slug/update-owner-form" do
    context "as a GDS Editor" do
      before { login_as_gds_editor }

      it "returns 200 OK" do
        get "/services/aardvark-wardens/update-owner-form"

        expect(response).to have_http_status(:ok)
      end
    end

    context "as a department user (even) from the owning department" do
      before { login_as_department_user(organisation_slug: owning_department) }

      it "returns 403 Forbidden" do
        get "/services/aardvark-wardens/update-owner-form"

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH /services/:service_slug/update-owner" do
    context "as a GDS Editor" do
      before { login_as_gds_editor }

      it "returns 200 OK" do
        patch "/services/aardvark-wardens/update-owner", params: { service: { organisation_slugs: "new-owner" } }

        expect(response).to redirect_to("/services/aardvark-wardens?filter=broken_links")
      end

      it "updates the organisation slugs" do
        patch "/services/aardvark-wardens/update-owner", params: { service: { organisation_slugs: "new-owner" } }

        expect(service.reload.organisation_slugs).to eq(%w[new-owner])
      end

      it "updates the organisation slugs with multiple owners" do
        patch "/services/aardvark-wardens/update-owner", params: { service: { organisation_slugs: "new-owner other-new-owner" } }

        expect(service.reload.organisation_slugs).to eq(%w[new-owner other-new-owner])
      end
    end

    context "as a department user (even) from the owning department" do
      before { login_as_department_user(organisation_slug: owning_department) }

      it "returns 403 Forbidden" do
        patch "/services/aardvark-wardens/update-owner", params: { service: { organisation_slugs: "new-owner" } }

        expect(response).to have_http_status(:forbidden)
      end

      it "does not update the organisation slugs" do
        patch "/services/aardvark-wardens/update-owner", params: { service: { organisation_slugs: "new-owner" } }

        expect(service.reload.organisation_slugs).to eq([owning_department])
      end
    end
  end
end
