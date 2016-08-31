require 'rails_helper'

feature 'The links for a local authority' do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])
    @time = Timecop.freeze("2016-07-14 11:34:09 +0100")
    @local_authority = FactoryGirl.create(:local_authority, status: '200', link_last_checked: @time - (60 * 60))
    @service = FactoryGirl.create(:service)
    @interaction_1 = FactoryGirl.create(:interaction)
    @interaction_2 = FactoryGirl.create(:interaction)
    @service_interaction_1 = FactoryGirl.create(:service_interaction, service: @service, interaction: @interaction_1)
    @service_interaction_2 = FactoryGirl.create(:service_interaction, service: @service, interaction: @interaction_2)
  end

  describe "when no links exist for the service interaction" do
    before do
      visit local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service.slug)
    end

    it "shows an empty cell for the link next to the interactions" do
      expect(page).to have_table_row("#{@interaction_1.lgil_code}", "#{@interaction_1.label}", 'No link', 'Add link')
      expect(page).to have_table_row("#{@interaction_2.lgil_code}", "#{@interaction_2.label}", 'No link', 'Add link')
    end

    it "shows an empty cell when editing a blank link" do
      within('.table') { click_on('Add link', match: :first) }
      expect(page.find_by_id('link_url').value).to be_blank
    end

    it "allows us to save a new link and view it" do
      within('.table') { click_on('Add link', match: :first) }
      fill_in('link_url', with: 'http://angus.example.com/new-link')
      click_on('Save')

      expect(page).to have_table_row("#{@interaction_1.lgil_code}", "#{@interaction_1.label} http://angus.example.com/new-link", 'Link not checked', 'Edit link')
      expect(page).to have_content('Link has been saved.')
    end

    it "shows the name of the local authority" do
      within('.table') { click_on('Add link', match: :first) }
      expect(page).to have_css('h1', text: @local_authority.name)
      expect(page).to have_link(@local_authority.homepage_url)
      expect(page).to have_content('Good Checked about 1 hour ago')
      expect(page).to have_css(".label-success")
      expect(page).not_to have_css(".label-danger")
    end

    it "does not save invalid links" do
      within('.table') { click_on('Add link', match: :first) }
      expect { click_on('Save') }.to change { Link.count }.by(0)
      expect(page).to have_content('Please enter a valid link')
    end

    it "does not show a delete button after clicking on add" do
      within('.table') { click_on('Add link', match: :first) }
      expect(page).not_to have_button("Delete")
    end

    it "shows 'No link' in the 'Link status' column if the interaction has no link" do
      visit local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service.slug)

      expect(page).to have_table_row("#{@interaction_1.lgil_code}", "#{@interaction_1.label}", 'No link', 'Add link')

      within("##{@interaction_1.lgil_code} .status") do
        expect(page).not_to have_css(".label-success")
        expect(page).not_to have_css(".label-danger")
      end
    end
  end

  describe "when links exist for the service interaction" do
    before do
      @link_1 = FactoryGirl.create(:link, local_authority: @local_authority, service_interaction: @service_interaction_1, status: "200", link_last_checked: @time - (60 * 60))
      @link_2 = FactoryGirl.create(:link, local_authority: @local_authority, service_interaction: @service_interaction_2)
      visit local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service.slug)
    end

    it "shows the url for the link next to the relevant interaction" do
      expect(page).to have_table_row("#{@interaction_1.lgil_code}", "#{@interaction_1.label} #{@link_1.url}", 'Good Checked about 1 hour ago', 'Edit link')
      expect(page).to have_table_row("#{@interaction_2.lgil_code}", "#{@interaction_2.label} #{@link_2.url}", 'Link not checked', 'Edit link')
    end

    it "shows the urls as clickable links" do
      expect(page).to have_link("#{@link_1.url}", href: "#{@link_1.url}")
      expect(page).to have_link("#{@link_2.url}", href: "#{@link_2.url}")
    end

    it "allows us to edit a link" do
      expect(page).to have_link('Edit link',
        href: edit_local_authority_service_interaction_links_path(
          local_authority_slug: @local_authority.slug,
          service_slug: @service.slug,
          interaction_slug: @interaction_1.slug
        )
      )
      within('.table') { click_on('Edit link', match: :first) }
      expect(page).to have_field('link_url', with: "#{@link_1.url}")
      expect(page).to have_button('Save')
    end

    it "allows us to save an edited link and view it" do
      within('.table') { click_on('Edit link', match: :first) }
      fill_in('link_url', with: 'http://angus.example.com/changed-link')
      click_on('Save')

      expect(page).to have_table_row("#{@interaction_1.lgil_code}", "#{@interaction_1.label} http://angus.example.com/changed-link", 'Link not checked', 'Edit link')
      expect(page).to have_table_row("#{@interaction_2.lgil_code}", "#{@interaction_2.label} #{@link_2.url}", 'Link not checked', 'Edit link')
      expect(page).to have_content('Link has been saved.')
    end

    it "does not save an edited link when 'Cancel' is clicked" do
      within('.table') { click_on('Edit link', match: :first) }
      fill_in('link_url', with: 'http://angus.example.com/changed-link')
      click_on('Cancel')

      expect(page).to have_link("#{@link_1.url}", href: "#{@link_1.url}")
    end

    it "shows a warning if the URL is not a valid URL" do
      within('.table') { click_on('Edit link', match: :first) }
      fill_in('link_url', with: 'linky loo')
      click_on('Save')

      expect(page).to have_content('Please enter a valid link')
      expect(page).to have_field('link_url', with: 'linky loo')
      expect(page).to have_css('.has-error')
    end

    it "allows us to delete a link" do
      within('.table') { click_on('Edit link', match: :first) }
      fill_in('link_url', with: 'http://angus.example.com/link-to-delete')
      click_on('Save')

      expect(page).to have_table_row("#{@interaction_1.lgil_code}", "#{@interaction_1.label} http://angus.example.com/link-to-delete", 'Link not checked', 'Edit link')

      within('.table') { click_on('Edit link', match: :first) }
      click_on('Delete')

      expect(page).to have_table_row("#{@interaction_1.lgil_code}", "#{@interaction_1.label}", 'No link', 'Add link')
    end

    it "shows a 'Good' link status and time the link was last checked in the 'Link status' column when a link returns a 200 status code" do
      within("##{@interaction_1.lgil_code} .status") do
        expect(page).to have_css(".label-success")
        expect(page).not_to have_css(".label-danger")
        expect(page).to have_content('Good Checked about 1 hour ago')
      end
    end

    it "shows 'Link not checked' in the 'Link status' column after a link has been updated" do
      @link_1.url = "#{@local_authority.homepage_url}/new-link"
      @link_1.save
      visit local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service.slug)

      within("##{@interaction_1.lgil_code} .status") do
        expect(page).to have_content("Link not checked")
        expect(page).not_to have_css(".label")
      end
    end

    it "shows a 'Broken Link 404' and the time the link was last checked in the 'Link status' column when a link returns a 404 status code" do
      @link_1.status = '404'
      @link_1.save
      visit local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service.slug)

      within("##{@interaction_1.lgil_code} .status") do
        expect(page).to have_content("Broken Link 404 Checked about 1 hour ago")
        expect(page).not_to have_css(".label-success")
        expect(page).to have_css(".label-danger")
      end
    end

    it "shows 'No link' and no time when there is no link" do
      @link_1.destroy
      visit local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service.slug)

      within("##{@interaction_1.lgil_code} .status") do
        expect(page).to have_content("No link")
        expect(page).not_to have_css(".label")
      end
    end
  end

  describe "homepage link status CSV" do
    it "should show a CSV" do
      visit '/check_homepage_links_status.csv'
      expect(page.body).to include("status,count\n")
      expect(page.body.count("\n")).to be > 1
    end
  end

  describe "interaction link status CSV" do
    before do
      FactoryGirl.create(:link, status: '200', link_last_checked: @time - (60 * 60))
    end

    it "should show a CSV" do
      visit '/check_links_status.csv'
      expect(page.body).to include("status,count\n")
      expect(page.body.count("\n")).to be > 1
    end
  end
end
