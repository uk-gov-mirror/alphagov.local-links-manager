require 'rails_helper'

feature "The services index page for a local authority" do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])
    @local_authority = FactoryGirl.create(:local_authority, name: 'Angus', tier: 'district')
    visit local_authority_services_path(local_authority_slug: @local_authority.slug)
  end

  describe "with no services present" do
    it "shows a message that no services are present" do
      expect(page).to have_content 'No local services found'
    end
  end

  describe "with services present" do
    before do
      @service_1 = FactoryGirl.create(:service, label: 'All councils', lgsl_code: 1, tier: 'all')
      @service_2 = FactoryGirl.create(:service, label: 'County and unitary only', lgsl_code: 2, tier: 'county/unitary')
      @service_3 = FactoryGirl.create(:service, label: 'District and unitary only', lgsl_code: 3, tier: 'district/unitary')
      @service_4 = FactoryGirl.create(:service, label: 'Unknown', lgsl_code: 4, tier: nil)
      visit local_authority_services_path(@local_authority.slug)
    end

    it "shows only the services provided by the authority according to its' tier with links to their individual pages" do
      expect(page).to have_content 'Local Government Services (2)'
      expect(page).to have_link('All councils', href: local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service_1.slug))
      expect(page).to have_link('District and unitary only', href: local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service_3.slug))
    end

    it "shows each service's LGSL codes in the table" do
      expect(page).to have_content 'LGSL Code'
      expect(page).to have_css('td.lgsl_code', text: 1)
      expect(page).to have_css('td.lgsl_code', text: 3)
    end
  end
end
