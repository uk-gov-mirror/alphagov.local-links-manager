RSpec.describe "Council page" do
  let!(:local_authority) { create(:district_council, slug: "north-midlands") }

  it_behaves_like "redirects non-GDS Editors to services page", "/local_authorities"
  it_behaves_like "redirects non-GDS Editors to services page", "/local_authorities/north-midlands"
  it_behaves_like "redirects non-GDS Editors to services page", "/local_authorities/north-midlands/edit_url"
  it_behaves_like "redirects non-GDS Editors to services page", "/local_authorities/north-midlands/download_links_form"
  it_behaves_like "redirects non-GDS Editors to services page", "/local_authorities/north-midlands/upload_links_form"

  describe "GET #index" do
    context "when there is sufficient data" do
      it "returns http succcess" do
        login_as_gds_editor

        get "/local_authorities"
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "GET #show" do
    it "returns http success" do
      login_as_gds_editor

      get "/local_authorities/north-midlands"
      expect(response).to have_http_status(200)
    end
  end

  describe "PATCH local_authorities/:local_authority_slug" do
    context "as a GDS Editor" do
      before { login_as_gds_editor }

      it "does the update and returns 200 OK" do
        patch "/local_authorities/north-midlands", params: { homepage_url: "https://www.changed.com" }

        expect(response).to redirect_to("/local_authorities/north-midlands")
        expect(local_authority.reload.homepage_url).to eq("https://www.changed.com")
      end
    end

    context "as a department user" do
      before { login_as_department_user }

      it "does not update and returns 403 Forbidden " do
        patch "/local_authorities/north-midlands", params: { homepage_url: "https://www.changed.com" }

        expect(response).to have_http_status(:forbidden)
        expect(local_authority.reload.homepage_url).to eq("http://www.angus.gov.uk")
      end
    end
  end

  describe "POST local_authorities/:local_authority_slug/download_links_csv" do
    context "as a GDS Editor" do
      before { login_as_gds_editor }

      it "returns 200 OK" do
        post "/local_authorities/north-midlands/download_links_csv", params: { links_status_checkbox: %w[ok] }

        expect(response).to have_http_status(:ok)
      end
    end

    context "as a department user" do
      before { login_as_department_user }

      it "returns 403 Forbidden " do
        post "/local_authorities/north-midlands/download_links_csv", params: { links_status_checkbox: %w[ok] }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST local_authorities/:local_authority_slug/upload_links_csv" do
    context "with an empty upload" do
      context "as a GDS Editor" do
        before { login_as_gds_editor }

        it "returns 302 found" do
          post "/local_authorities/north-midlands/upload_links_csv", params: {}

          expect(response).to have_http_status(:found)
        end
      end

      context "as a department user" do
        before { login_as_department_user }

        it "returns 403 Forbidden" do
          post "/local_authorities/north-midlands/upload_links_csv", params: {}

          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
