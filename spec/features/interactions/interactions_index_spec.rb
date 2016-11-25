require 'rails_helper'

feature "The interactions index page for a service provided by a local authority" do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])
    @local_authority = FactoryGirl.create(:county_council)
    @service_1 = FactoryGirl.create(:service, :county_unitary)
    visit local_authority_with_service_path(local_authority_slug: @local_authority.slug, service_slug: @service_1.slug)
  end

  it "displays the LGSL code" do
    expect(page).to have_content("Service code #{@service_1.lgsl_code}")
  end

  it 'has a list of breadcrumbs pointing back to the authority and service that lead us here' do
    within '.breadcrumb' do
      expect(page).to have_link 'Local links', href: root_path
      expect(page).to have_link @local_authority.name, href: local_authority_path(@local_authority.slug)
      expect(page).to have_text @service_1.label
    end
  end

  describe "with no interactions present" do
    it "shows a message that no interactions are present" do
      expect(page).to have_content("No local interactions found")
    end
  end

  describe "with interactions present" do
    before do
      @interaction_1 = FactoryGirl.create(:interaction, label: 'Interaction 1', lgil_code: 3)
      @service_interaction = FactoryGirl.create(:service_interaction, service_id: @service_1.id, interaction_id: @interaction_1.id)
      visit local_authority_with_service_path(local_authority_slug: @local_authority.slug, service_slug: @service_1.slug)
    end

    it "shows the local authority name" do
      expect(page).to have_css('h1', text: @local_authority.name)
    end

    it "doesn't show the available interactions for the service if there aren't any links for them" do
      expect(page).to have_content('Interactions and links')
      expect(page).not_to have_content('Interaction 1')
    end
  end
end
