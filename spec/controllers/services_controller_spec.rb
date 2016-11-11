require 'rails_helper'

RSpec.describe ServicesController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      login_as_stub_user
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
