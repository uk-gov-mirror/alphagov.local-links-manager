require 'rails_helper'

RSpec.describe InteractionsController, type: :controller do
  before do
    @local_authority = FactoryGirl.create(:local_authority, name: 'Angus')
    @service = FactoryGirl.create(:service, label: 'Service 1', lgsl_code: 1)
    @interaction = FactoryGirl.create(:interaction, label: 'Interaction 1', lgil_code: 3)
  end

  describe "GET #index" do
    it "returns http success" do
      login_as_stub_user
      get :index, params: { local_authority_slug: @local_authority.slug, service_slug: @service.slug }
      expect(response).to have_http_status(:success)
    end
  end
end
