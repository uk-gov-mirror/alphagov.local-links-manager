require 'rails_helper'

feature "The local authority show page" do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])
    @local_authority = create(:district_council)
    visit local_authority_path(local_authority_slug: @local_authority.slug)
  end

  it 'has a list of breadcrumbs pointing back to the authority that lead us here' do
    within '.breadcrumb' do
      expect(page).to have_link 'Local links', href: root_path
      expect(page).to have_text @local_authority.name
    end
  end

  describe "with no local authority homepage url" do
    it "shows the 'Add link' button" do
      click_on('Edit link')
      fill_in('local_authority_homepage_url', with: '')
      click_on('Save')
      expect(page).to have_content('Homepage link has been saved.')
      expect(page).to have_link('Add link')
    end

    it "renders the local authority services page successfully" do
      ni_local_authority = create(:district_council)
      visit local_authority_path(local_authority_slug: ni_local_authority.slug)
      expect(page.status_code).to eq(200)

      within(:css, ".page-title") do
        expect(page).not_to have_link("/local_authorities/#{ni_local_authority.slug}/services")
      end
    end

    it "displays 'No link'" do
      @local_authority.homepage_url = nil
      @local_authority.save
      visit local_authority_path(local_authority_slug: @local_authority.slug)
      within(:css, ".page-title") do
        expect(page).to have_content('No link')
      end
    end

    it "does not display 'Link not checked'" do
      @local_authority.homepage_url = nil
      @local_authority.save
      visit local_authority_path(local_authority_slug: @local_authority.slug)
      within(:css, ".page-title") do
        expect(page).not_to have_content('Link not checked')
      end
    end
  end

  describe "with services present" do
    before do
      @service = create(:service, :all_tiers)
      @disabled_service = create(:disabled_service)
      @link = create_service_interaction_link(@service)
      create_service_interaction_link(@disabled_service)
      visit local_authority_path(@local_authority)
    end

    let(:http_status) { 200 }

    it "shows only the enabled services provided by the authority according to its tier with links to their individual pages" do
      expect(page).to have_content 'Services and links'
      expect(page).to have_link(@link.service.label, href: local_authority_with_service_path(local_authority_slug: @local_authority.slug, service_slug: @link.service.slug))
    end

    it "does not show the disabled service interaction" do
      expect(page).not_to have_content(@disabled_service.label)
    end

    it "shows each service's LGSL codes in the table" do
      expect(page).to have_content 'Code'
      expect(page).to have_css('td.lgsl', text: @link.service.lgsl_code)
    end

    it 'shows the link status as Good Link when the status is 200' do
      within(:css, "tr[data-interaction-id=\"#{@link.interaction.id}\"]") do
        expect(page).to have_text 'Good'
      end
    end

    it 'shows the link last checked details' do
      expect(page).to have_text @link.link_last_checked
    end

    it 'should have a link to Edit Link' do
      expect(page).to have_link 'Edit link', href: edit_link_path(@local_authority, @service, @link.interaction)
    end

    context "when the status is 404" do
      let(:http_status) { 404 }
      it 'shows the link status as Broken Link 404 when the status is 404' do
        expect(page).to have_text 'Broken Link 404'
      end
    end
  end

  def create_service_interaction_link(service)
    service_interaction = create(:service_interaction, service: service)

    create(:link, local_authority: @local_authority, service_interaction: service_interaction, status: http_status)
  end
end
