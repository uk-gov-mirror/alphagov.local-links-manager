require 'rails_helper'

RSpec.describe LinksController, type: :controller do
  before do
    login_as_stub_user
    @local_authority = FactoryGirl.create(:local_authority, name: 'Angus')
    @service = FactoryGirl.create(:service, label: 'Service 1', lgsl_code: 1)
    @interaction = FactoryGirl.create(:interaction, label: 'Interaction 1', lgil_code: 3)
  end

  describe 'GET edit' do
    it 'retrieves HTTP success' do
      get :edit, local_authority_slug: @local_authority.slug, service_slug: @service.slug, interaction_slug: @interaction.slug
      expect(response).to have_http_status(:success)
    end
  end

  describe 'delete links' do
    it 'handles deletion of links that have already been deleted' do
      delete :destroy, local_authority_slug: @local_authority.slug, service_slug: @service.slug, interaction_slug: @interaction.slug
      expect(response).to have_http_status(302)
      expect(flash[:danger]).not_to be_present
    end
  end

  describe 'GET homepage_links_status_csv' do
    it "retrieves HTTP success" do
      get :homepage_links_status_csv
      expect(response).to have_http_status(:success)
      expect(response.headers['Content-Type']).to eq('text/csv')
    end
  end

  describe 'GET links_status_csv' do
    it "retrieves HTTP success" do
      get :links_status_csv
      expect(response).to have_http_status(:success)
      expect(response.headers['Content-Type']).to eq('text/csv')
    end
  end
end
