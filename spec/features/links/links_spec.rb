require 'rails_helper'

feature 'The links for a local authority' do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])
    @local_authority = FactoryGirl.create(:local_authority, name: 'Angus', tier: 'county')
    @service = FactoryGirl.create(:service, label: 'Service', lgsl_code: 1, tier: 'county/unitary')
    @interaction_1 = FactoryGirl.create(:interaction, label: 'Interaction 1', lgil_code: 3)
    @interaction_2 = FactoryGirl.create(:interaction, label: 'Interaction 2', lgil_code: 4)
    @service_interaction_1 = FactoryGirl.create(:service_interaction, service: @service, interaction: @interaction_1)
    @service_interaction_2 = FactoryGirl.create(:service_interaction, service: @service, interaction: @interaction_2)
  end

  describe "when no links exist for the service interaction" do
    before do
      visit local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service.slug)
    end

    it "shows an empty cell for the link next to the interactions" do
      expect(page).to have_table_row('3', 'Interaction 1', 'n/a')
      expect(page).to have_table_row('4', 'Interaction 2', 'n/a')
    end
  end

  describe "when links exist for the service interaction" do
    before do
      FactoryGirl.create(:link, url: 'http://angus.example.com/service-interaction-1', local_authority: @local_authority, service_interaction: @service_interaction_1)
      FactoryGirl.create(:link, url: 'https://angus.example.com/service-interaction-2', local_authority: @local_authority, service_interaction: @service_interaction_2)
      visit local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service.slug)
    end

    it "shows the url for the link next to the relevant interaction" do
      expect(page).to have_table_row('3', 'Interaction 1', 'http://angus.example.com/service-interaction-1')
      expect(page).to have_table_row('4', 'Interaction 2', 'https://angus.example.com/service-interaction-2')
    end

    it "shows the urls as clickable links" do
      expect(page).to have_link('http://angus.example.com/service-interaction-1', href: 'http://angus.example.com/service-interaction-1')
      expect(page).to have_link('https://angus.example.com/service-interaction-2', href: 'https://angus.example.com/service-interaction-2')
    end
  end
end
