require 'rails_helper'

RSpec.describe ServicesController, type: :controller do
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
        create(:service)
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #show" do
    it "returns http success" do
      login_as_stub_user
      service = create(:service)
      get :show, params: { service_slug: service.slug }
      expect(response).to have_http_status(:success)
    end
  end
end
