feature "The services index page" do
  before do
    User.create!(email: "user@example.com", name: "Test User", permissions: %w[signin])

    @aardvark = create(:service, label: "Aardvark Wardens")
    @zebra = create(:service, label: "Zebra Fouling", broken_link_count: 1)
    create(:disabled_service)
    visit services_path
  end

  it "has a breadcrumb trail" do
    expect(page).to have_selector(".govuk-breadcrumbs__list")
  end

  it "displays a filter box" do
    expect(page).to have_selector(".js-gem-c-table__filter")
  end

  it "shows enabled services sorted by broken link count" do
    expect(page).to have_content("Services (2)")
    expect(page).to have_content("Zebra Fouling Not used on GOV.UK #{@zebra.lgsl_code} 1")
    expect(page).to have_content("Aardvark Wardens Not used on GOV.UK #{@aardvark.lgsl_code} 0")
    expect("Zebra Fouling").to appear_before("Aardvark Wardens")
  end
end
