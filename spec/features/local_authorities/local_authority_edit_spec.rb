require 'rails_helper'

feature "The local authorities edit page" do
  before do
    FactoryGirl.create(:user)
    @local_authority = FactoryGirl.create(:local_authority, name: 'Angus', tier: 'district')
    visit local_authority_services_path(local_authority_slug: @local_authority.slug)
  end

  it 'allows us to edit the homepage url' do
    click_on('Edit link')
    fill_in('local_authority_homepage_url', with: 'http://angus.example.com/changed-link')
    click_on('Save')
    expect(page).to have_content('Homepage link has been saved.')
    expect(page).to have_link('angus.example.com/changed-link')
  end

  it 'allows us to cancel editing the homepage url' do
    click_on('Edit link')
    click_on('Cancel')
    expect(page).to have_current_path(local_authority_services_path(local_authority_slug: @local_authority.slug))
    expect(page).to have_link(@local_authority.friendly_url)
  end

  it 'displays the link again when validation fails' do
    click_on('Edit link')
    fill_in('local_authority_homepage_url', with: 'invalid URL')
    click_on('Save')
    expect(page).to have_content('Please enter a valid link')
    expect(page).to have_field('local_authority_homepage_url', with: 'invalid URL')
    expect(page).to have_css('.has-error')
  end
end
