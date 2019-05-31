feature "The services index page" do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: %w[signin])

    @aardvark = create(:service, label: 'Aardvark Wardens')
    @zebra = create(:service, label: 'Zebra Fouling', broken_link_count: 1)
    create(:disabled_service)
    visit services_path
  end

  it "has a breadcrumb trail" do
    expect(page).to have_selector('.breadcrumb')
  end

  it "displays a filter box" do
    expect(page).to have_selector('.filter-control-full-width')
  end

  it "shows enabled services sorted by broken link count" do
    expect(page).to have_content('2 services')
    expect(page).to have_content("Zebra Fouling\n1")
    expect(page).to have_content("Aardvark Wardens\n0")
    expect('Zebra Fouling').to appear_before('Aardvark Wardens')
  end
end
