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
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET #show" do
    it "returns http success" do
      login_as_gds_editor

      get "/local_authorities/north-midlands"
      expect(response).to have_http_status(:ok)
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

  describe "GET bad_homepage_url_and_status_csv" do
    it "retrieves HTTP success" do
      login_as_gds_editor

      get "/bad_homepage_url_status.csv"
      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Type"]).to eq("text/csv")
    end
  end

  describe "POST local_authorities/:local_authority_slug/download_links_csv" do
    context "as a GDS Editor" do
      before { login_as_gds_editor }

      it "returns 200 OK" do
        post "/local_authorities/north-midlands/download_links_csv", params: { links_status_checkbox: %w[ok broken] }

        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Type"]).to eq("text/csv")
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

    context "with a valid CSV" do
      before { @local_authority = create(:local_authority, gss: "S1") }
      let(:path) { Rails.root.join("spec/lib/local-links-manager/import/fixtures/imported_links.csv") }
      let(:csv) { Rack::Test::UploadedFile.new(path, "text/csv", true) }
      let(:url_regex) { /http:\/\/.+\/local_authorities\/north-midlands/ }

      it "retrieves HTTP found" do
        login_as_gds_editor

        post "/local_authorities/north-midlands/upload_links_csv", params: { csv: }

        expect(response.status).to eq(302)
        expect(response.location).to match(url_regex)
        expect(response.headers["Content-Type"]).to eq("text/html; charset=utf-8")
      end
    end
  end
end
