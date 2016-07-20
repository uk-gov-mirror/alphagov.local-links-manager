require 'rails_helper'

feature "The local authorities edit page" do
  before do
    FactoryGirl.create(:user)
  end

  context "editing the homepage_url" do
    before do
      @local_authority = FactoryGirl.create(:local_authority)
      visit local_authority_services_path(local_authority_slug: @local_authority.slug)
      click_on('Edit link')
    end

    it 'allows us to edit the homepage url and show changed link and status' do
      fill_in('local_authority_homepage_url', with: 'http://angus.example.com/changed-link')
      click_on('Save')
      expect(page).to have_content('Homepage link has been saved.')

      within(".page-title") do
        expect(page).to have_link('angus.example.com/changed-link')
        expect(page).to have_content("Link not checked")
        expect(page).not_to have_css(".label")
      end
    end

    it 'allows us to cancel editing the homepage url' do
      click_on('Cancel')
      expect(page).to have_current_path(local_authority_services_path(local_authority_slug: @local_authority.slug))
      expect(page).to have_link(@local_authority.homepage_url)
    end

    it 'displays the link again when validation fails' do
      fill_in('local_authority_homepage_url', with: 'invalid URL')
      click_on('Save')
      expect(page).to have_content('Please enter a valid link')
      expect(page).to have_field('local_authority_homepage_url', with: 'invalid URL')
      expect(page).to have_css('.has-error')
    end
  end

  context "viewing a local authority with 200 homepage" do
    before do
      @time = Timecop.freeze("2016-07-14 11:34:09 +0100")
      @local_authority = FactoryGirl.create(:local_authority, status: "200", link_last_checked: @time - (60 * 60))
      visit local_authority_services_path(local_authority_slug: @local_authority.slug)
    end

    after { Timecop.return }

    it "shows a 'Good' link status and time the link was last checked in the 'Link status' column when a link returns a 200 status code" do
      within(".page-title") do
        expect(page).to have_css(".label-success")
        expect(page).not_to have_css(".label-danger")
        expect(page).to have_content('Good Checked about 1 hour ago')
      end
    end
  end

  context "viewing a local authority with 404 homepage" do
    before do
      @time = Timecop.freeze("2016-07-14 11:34:09 +0100")
      @local_authority = FactoryGirl.create(:local_authority, status: "404", link_last_checked: @time - (60 * 60))
      visit local_authority_services_path(local_authority_slug: @local_authority.slug)
    end

    after { Timecop.return }

    it "shows a 'Broken Link 404' and the time the link was last checked in the 'Link status' column when a link returns a 404 status code" do
      within(".page-title") do
        expect(page).to have_content("Broken Link 404 Checked about 1 hour ago")
        expect(page).not_to have_css(".label-success")
        expect(page).to have_css(".label-danger")
      end
    end
  end
end
