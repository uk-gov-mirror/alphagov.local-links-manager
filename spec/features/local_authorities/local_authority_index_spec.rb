require 'rails_helper'

feature "The local authorities index page" do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])
    visit root_path
  end

  it 'has no breadcrumb trail because this is the root' do
    expect(page).to have_no_selector('.breadcrumb')
  end

  describe "with no local authorities present" do
    it "shows a message if no local authorities are present" do
      expect(page).to have_content 'No local authorities found'
    end
  end

  describe "with local authorities present" do
    before do
      @angus = FactoryGirl.create(:local_authority, name: 'Angus')
      @zorro = FactoryGirl.create(:local_authority, name: 'Zorro Council', gss: 'XXXXXXXXX', snac: 'ZZZZ')
      FactoryGirl.create(:link, :with_service_interaction, local_authority: @zorro, status: 500)

      visit root_path
    end

    it "shows the available local authorities with links to their respective pages" do
      expect(page).to have_content '2 local authorities'
      expect(page).to have_link('Angus', href: local_authority_services_path(@angus.slug))
      expect(page).to have_link('Zorro Council', href: local_authority_services_path(@zorro.slug))
    end

    describe "clicking on the LA name on the index page" do
      it "takes you to the show page for that LA" do
        click_link('Angus')
        expect(current_path).to eq(local_authority_services_path(@angus.slug))
      end
    end

    context "the sort order" do
      it "defaults to Number of Broken Links, but we can change it to A-Z" do
        expect('Zorro Council').to appear_before "Angus"
        change_sort_order_to_alphabetical
        expect('Angus').to appear_before 'Zorro Council'
        change_sort_order_to_number_of_broken_links
        expect('Zorro Council').to appear_before "Angus"
      end
    end
  end

  def change_sort_order_to_alphabetical
    click_button "Sort by: Number of broken links"
    within 'ul.dropdown-menu' do
      click_link 'A-Z'
    end
  end

  def change_sort_order_to_number_of_broken_links
    click_button "Sort by: A-Z"
    within 'ul.dropdown-menu' do
      click_link 'Number of broken links'
    end
  end
end
