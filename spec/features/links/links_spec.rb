require 'rails_helper'

feature 'The links for a local authority' do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])
    @time = Timecop.freeze("2016-07-14 11:34:09 +0100")
    @local_authority = create(:local_authority, status: "ok", link_last_checked: @time - (60 * 60))
    @service = create(:service)
    @interaction_1 = create(:interaction)
    @interaction_2 = create(:interaction)
    @service_interaction_1 = create(:service_interaction, service: @service, interaction: @interaction_1)
    @service_interaction_2 = create(:service_interaction, service: @service, interaction: @interaction_2)
  end

  describe "when no links exist for the service interaction" do
    before do
      visit local_authority_with_service_path(local_authority_slug: @local_authority.slug, service_slug: @service.slug)
    end

    it "does not show the link" do
      expect(page).not_to have_table_row(@interaction_1.label.to_s)
      expect(page).not_to have_table_row(@interaction_2.label.to_s)
    end
  end

  describe "when links exist for the service interaction" do
    before do
      @link_1 = create(:link, local_authority: @local_authority, service_interaction: @service_interaction_1, status: "ok", link_last_checked: @time - (60 * 60))
      @link_2 = create(:link, local_authority: @local_authority, service_interaction: @service_interaction_2)
      visit local_authority_with_service_path(local_authority_slug: @local_authority.slug, service_slug: @service.slug)
    end

    it "shows the url for the link next to the relevant interaction" do
      expect(page).to have_table_row("#{@interaction_1.label} #{@link_1.url}", 'Good about 1 hour ago', 'Edit link')
      expect(page).to have_table_row("#{@interaction_2.label} #{@link_2.url}", 'Link not checked', 'Edit link')
    end

    it "shows the urls as clickable links" do
      expect(page).to have_link(@link_1.url.to_s, href: @link_1.url.to_s)
      expect(page).to have_link(@link_2.url.to_s, href: @link_2.url.to_s)
    end

    it "allows us to edit a link" do
      expect(page).to have_link('Edit link',
        href: edit_link_path(
          local_authority_slug: @local_authority.slug,
          service_slug: @service.slug,
          interaction_slug: @interaction_1.slug
        )
      )
      within('.table') { click_on('Edit link', match: :first) }
      expect(page).to have_text(@service.label)
      expect(page).to have_text(@interaction_1.label)
      expect(page).to have_field('link_url', with: @link_1.url.to_s)
      expect(page).to have_button('Update')
    end

    it "allows us to save an edited link and view it" do
      within('.table') { click_on('Edit link', match: :first) }
      fill_in('link_url', with: 'http://angus.example.com/changed-link')
      click_on('Update')

      expect(page).to have_table_row("#{@interaction_1.label} http://angus.example.com/changed-link", 'Link not checked', 'Edit link')
      expect(page).to have_table_row("#{@interaction_2.label} #{@link_2.url}", 'Link not checked', 'Edit link')
      expect(page).to have_content('Link has been saved.')
    end

    it "does not save an edited link when 'Cancel' is clicked" do
      within('.table') { click_on('Edit link', match: :first) }
      fill_in('link_url', with: 'http://angus.example.com/changed-link')
      click_on('Cancel')

      expect(page).to have_link(@link_1.url.to_s, href: @link_1.url.to_s)
    end

    it "shows a warning if the URL is not a valid URL" do
      within('.table') { click_on('Edit link', match: :first) }
      fill_in('link_url', with: 'linky loo')
      click_on('Update')

      expect(page).to have_content('Please enter a valid link')
      expect(page).to have_field('link_url', with: 'linky loo')
      expect(page).to have_css('.has-error')
    end

    it "allows us to delete a link" do
      within('.table') { click_on('Edit link', match: :first) }
      fill_in('link_url', with: 'http://angus.example.com/link-to-delete')
      click_on('Update')

      expect(page).to have_table_row("#{@interaction_1.label} http://angus.example.com/link-to-delete", 'Link not checked', 'Edit link')

      within('.table') { click_on('Edit link', match: :first) }
      click_on('Delete')

      expect(page).not_to have_table_row(@interaction_1.label.to_s)
    end

    it "shows a 'Good' link status and time the link was last checked in the 'Link status' column when a link returns a 200 status code" do
      within("##{@interaction_1.lgil_code} .status") do
        expect(page).to have_css(".label-success")
        expect(page).not_to have_css(".label-danger")
        expect(page).not_to have_css(".label-warning")
        expect(page).to have_content('Good about 1 hour ago')
      end
    end

    it "shows 'Link not checked' in the 'Link status' column after a link has been updated" do
      @link_1.url = "#{@local_authority.homepage_url}/new-link"
      @link_1.save
      visit local_authority_with_service_path(local_authority_slug: @local_authority.slug, service_slug: @service.slug)

      within("##{@interaction_1.lgil_code} .status") do
        expect(page).to have_content("Link not checked")
        expect(page).not_to have_css(".label")
      end
    end

    it "shows 'Broken: 404 error (page not found)' and the time the link was last checked in the 'Link status' column when a link returns a 404 status code" do
      @link_1.status = "broken"
      @link_1.problem_summary = "404 error (page not found)"
      @link_1.link_errors = ["Received 404 response from the server."]
      @link_1.save
      visit local_authority_with_service_path(local_authority_slug: @local_authority.slug, service_slug: @service.slug)

      within("##{@interaction_1.lgil_code} .status") do
        expect(page).to have_content("Broken: 404 error (page not found)")
        expect(page).not_to have_css(".label-success")
        expect(page).not_to have_css(".label-warning")
        expect(page).to have_css(".label-danger")
      end
    end

    it "shows 'Note: Slow page load' and the time the link was last checked in the 'Link status' column when a link has multiple redirects" do
      @link_1.status = "caution"
      @link_1.problem_summary = "Slow page load"
      @link_1.link_warnings = [
        "Several redirects are set up on this URL - it will load slowly. Find where the content is now hosted and link to that instead."
      ]
      @link_1.save
      visit local_authority_with_service_path(local_authority_slug: @local_authority.slug, service_slug: @service.slug)

      within("##{@interaction_1.lgil_code} .status") do
        expect(page).to have_content("Note: Slow page load")
        expect(page).not_to have_css(".label-success")
        expect(page).not_to have_css(".label-danger")
        expect(page).to have_css(".label-warning")
      end
    end
  end

  describe "when links exist for the service interaction" do
    before do
      @link_1 = create(:link, local_authority: @local_authority, service_interaction: @service_interaction_1, status: "200", link_last_checked: @time - (60 * 60))
      @link_2 = create(:link, local_authority: @local_authority, service_interaction: @service_interaction_2)
    end

    it "returns a 404 if the supplied local authority doesn't exist" do
      expect {
        visit edit_link_path(local_authority_slug: "benidorm",
                      service_slug: @service.slug,
                      interaction_slug: @interaction_1.slug)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns a 404 if the supplied service doesn't exist" do
      expect {
        visit edit_link_path(local_authority_slug: @local_authority.slug,
                      service_slug: "bed-pans",
                      interaction_slug: @interaction_1.slug)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns a 404 if the supplied interaction doesn't exist" do
      expect {
        visit edit_link_path(local_authority_slug: @local_authority.slug,
                      service_slug: @service.slug,
                      interaction_slug: "buccaneering")
      }.to raise_error(ActiveRecord::RecordNotFound)
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
      create(:link, status: "ok", link_last_checked: @time - (60 * 60))
    end

    it "should show a CSV" do
      visit '/check_links_status.csv'
      expect(page.body).to include("status,count\n")
      expect(page.body.count("\n")).to be > 1
    end
  end
end
