RSpec.describe "Broken links page" do
  it_behaves_like "redirects non-GDS Editors to services page", "/"
end

describe "Broken links page" do
  before do
    login_as_gds_editor
    @local_authority = create(:local_authority, name: "North Midlands")
    @service = create(:service, label: "Aardvark Wardens")
    @interaction = create(:interaction, label: "Reporting")
    @service_interaction = create(:service_interaction, service: @service, interaction: @interaction)
  end

  context "GET edit" do
    it "GET edit handles URL passed in via flash" do
      get "/local_authorities/north-midlands/services/aardvark-wardens/reporting/edit"
      expect(response).to have_http_status(:ok)

      flash_hash = ActionDispatch::Flash::FlashHash.new
      flash_hash[:link_url] = "https://www.example.com"
      session["flash"] = flash_hash.to_session_value

      get "/local_authorities/north-midlands/services/aardvark-wardens/reporting/edit"
      expect(response).to have_http_status(:ok)
    end
  end

  context "GET homepage_links_status_csv" do
    it "returns a 200 response" do
      get "/check_homepage_links_status.csv"
      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Type"]).to eq("text/csv")
    end
  end

  context "GET links_status_csv" do
    it "returns a 200 response" do
      get "/check_links_status.csv"
      expect(response).to have_http_status(200)
      expect(response.headers["Content-Type"]).to eq("text/csv")
    end
  end

  context "GET bad_links_url_and_status_csv" do
    it "returns a 200 response" do
      get "/bad_links_url_status.csv"
      expect(response).to have_http_status(200)
      expect(response.headers["Content-Type"]).to eq("text/csv")
    end
  end
end
