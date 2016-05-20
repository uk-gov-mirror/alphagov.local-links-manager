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
      visit root_path
    end

    it "shows the available local authorities with links to their respective pages" do
      expect(page).to have_content 'Local Authorities (2)'
      expect(page).to have_link('Angus', href: local_authority_services_path(@angus.slug))
      expect(page).to have_link('Zorro Council', href: local_authority_services_path(@zorro.slug))
    end

    describe "clicking on the LA name on the index page" do
      it "takes you to the show page for that LA" do
        click_link('Angus')
        expect(current_path).to eq(local_authority_services_path(@angus.slug))
      end
    end
  end
end
