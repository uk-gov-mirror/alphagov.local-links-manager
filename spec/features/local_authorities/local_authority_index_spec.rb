require 'rails_helper'

feature "The local authorities index page" do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])

    @angus = FactoryGirl.create(:local_authority, name: 'Angus')
    @zorro = FactoryGirl.create(:local_authority, name: 'Zorro Council', broken_link_count: 1)
    visit local_authorities_path
  end

  it 'has a breadcrumb trail' do
    expect(page).to have_selector('.breadcrumb')
  end

  it "displays a filter box" do
    expect(page).to have_selector('.filter-control')
  end

  it "shows the available local authorities with links to their respective pages" do
    expect(page).to have_content '2 local authorities'
    expect(page).to have_link('Angus', href: local_authority_path(@angus.slug, filter: 'broken_links'))
    expect(page).to have_link('Zorro Council', href: local_authority_path(@zorro.slug, filter: 'broken_links'))
  end

  it "shows the count of broken links for each local authority" do
    expect(page).to have_content "Angus 0"
    expect(page).to have_content "Zorro Council 1"
  end

  describe "clicking on the LA name on the index page" do
    it "takes you to the show page for that LA" do
      click_link('Angus')
      expect(current_path).to eq(local_authority_path(@angus.slug))
    end
  end
end
