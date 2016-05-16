require 'rails_helper'

feature "The services index page for a local authority" do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])
    @local_authority = FactoryGirl.create(:local_authority, name: 'Angus', slug: 'angus')
    visit local_authority_services_path(local_authority_slug: @local_authority.slug)
  end

  describe "with no services present" do
    it "shows a message that no services are present" do
      expect(page).to have_content 'No local services found'
    end
  end

  describe "with services present" do
    before do
      @service_1 = FactoryGirl.create(:service, label: 'Service 1', slug: 'service-1', lgsl_code: 1)
      @service_2 = FactoryGirl.create(:service, label: 'Service 2', slug: 'service-2', lgsl_code: 2)
      visit local_authority_services_path(@local_authority.slug)
    end

    it "shows the available services with links to their individual pages" do
      expect(page).to have_content 'Local Government Services (2)'
      expect(page).to have_link('Service 1', href: local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service_1.slug))
      expect(page).to have_link('Service 2', href: local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service_2.slug))
    end

    it "shows each service's LGSL codes in the table" do
      expect(page).to have_content 'LGSL Code'
      expect(page).to have_css('td.lgsl_code', text: 1)
      expect(page).to have_css('td.lgsl_code', text: 2)
    end
  end
end
