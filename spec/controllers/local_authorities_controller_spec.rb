RSpec.describe LocalAuthoritiesController, type: :controller do
  describe "GET #index" do
    context "when there is missing data" do
      it "returns http server error" do
        login_as_stub_user
        expect { get :index }.to raise_error "Missing Data"
      end
    end

    context "when there is sufficient data" do
      it "returns http succcess" do
        login_as_stub_user
        create(:local_authority)
        get :index
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "GET #show" do
    before do
      @local_authority = create(:local_authority, name: 'Angus')
      @service = create(:service, label: 'Service 1', lgsl_code: 1)
    end

    it "returns http success" do
      login_as_stub_user
      get :show, params: { local_authority_slug: @local_authority.slug, service_slug: @service.slug }
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET bad_homepage_url_and_status_csv' do
    it "retrieves HTTP success" do
      login_as_stub_user
      get :bad_homepage_url_and_status_csv
      expect(response).to have_http_status(200)
      expect(response.headers['Content-Type']).to eq('text/csv')
    end
  end

  describe "GET download_links_csv" do
    before do
      @local_authority = create(:local_authority)
    end

    it "retrieves HTTP success" do
      login_as_stub_user
      get(
        :download_links_csv,
        params: {
          local_authority_slug: @local_authority.slug,
          ok: 'ok',
          broken: 'broken',
          caution: 'caution',
          missing: 'missing',
          pending: 'pending'
        }
      )
      expect(response).to have_http_status(200)
      expect(response.headers["Content-Type"]).to eq("text/csv")
    end
  end

  describe "POST upload_links_csv" do
    before { @local_authority = create(:local_authority) }
    let(:path) { File.join(Rails.root, 'spec/lib/local-links-manager/import/fixtures/imported_links.csv') }
    let(:csv) { Rack::Test::UploadedFile.new(path, 'text/csv', true) }
    let(:url_regex) { /http:\/\/.+\/local_authorities\/#{@local_authority.slug}/ }

    it "retrieves HTTP found" do
      login_as_stub_user
      post(:upload_links_csv, params: { local_authority_slug: @local_authority.slug, csv: csv })

      expect(response.status).to eq(302)
      expect(response.location).to match(url_regex)
      expect(response.headers["Content-Type"]).to eq("text/html; charset=utf-8")
    end
  end
end
