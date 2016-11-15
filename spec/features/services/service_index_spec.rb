require 'rails_helper'

feature "The services index page" do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])

    @aardvark = FactoryGirl.create(:service, label: 'Aardvark Wardens', lgsl_code: 1)
    @zebra = FactoryGirl.create(:service, label: 'Zebra Fouling', broken_link_count: 1, lgsl_code: 99)

    visit services_path
  end

  it 'has a breadcrumb trail ' do
    expect(page).to have_selector('.breadcrumb')
  end

  it "displays a filter box" do
    expect(page).to have_selector('.filter-control-full-width')
  end

  it "shows services sorted by broken link count" do
    expect(page).to have_content('2 services')
    expect(page).to have_content('99 Zebra Fouling 1')
    expect(page).to have_content('1 Aardvark Wardens 0')
    expect('Zebra Fouling').to appear_before('Aardvark Wardens')
  end

  context "with disabled services" do
    before do
      FactoryGirl.create(:disabled_service)
    end

    it "shows only shows enabled services" do
      expect(page).to have_content('2 services')
    end
  end
end
