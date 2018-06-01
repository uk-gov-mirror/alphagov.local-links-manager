require 'rails_helper'

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
        expect(response).to have_http_status(:success)
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
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET bad_homepage_url_and_status_csv' do
    it "retrieves HTTP success" do
      login_as_stub_user
      get :bad_homepage_url_and_status_csv
      expect(response).to have_http_status(:success)
      expect(response.headers['Content-Type']).to eq('text/csv')
    end
  end
end
