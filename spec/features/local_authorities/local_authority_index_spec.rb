describe "The local authority index page", type: :feature do
  before :each do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])
  end

  it "shows a message if no local authorities are present" do
    visit '/'

    expect(page).to have_content 'No local authorities found'
  end

  it "shows the available local authorities" do
    FactoryGirl.create(:local_authority, name: "Angus")
    FactoryGirl.create(:local_authority, name: "Zorro Council", gss: "XXXXXXXXX", snac: "ZZZZ")

    visit '/'

    expect(page).to have_content 'Local Authorities (2)'
    expect(page).to have_content 'Angus'
    expect(page).to have_content 'Zorro Council'
  end
end
