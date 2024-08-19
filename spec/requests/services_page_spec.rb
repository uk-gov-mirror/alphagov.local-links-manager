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

    context "as a GDS Editor" do
      before { login_as_gds_editor }

      it "returns 200 OK" do
        post "/services/aardvark-wardens/download_links_csv"

        expect(response).to have_http_status(:ok)
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
end
