require "gds_api/test_helpers/organisations"

RSpec.describe "Main menu" do
  include GdsApi::TestHelpers::Organisations

  context "as a normal user" do
    before do
      login_as_department_user
      stub_organisations_api_has_organisations_with_bodies([{ "title" => "Department of Randomness", "details" => { "slug" => "random-department" } }])
    end

    it "shows only the Services/Switch app menu items" do
      visit "/"

      within(".govuk-service-navigation__container") do
        expect(page).not_to have_link("Broken Links")
        expect(page).not_to have_link("Councils")
        expect(page).to have_link("Services")
        expect(page).to have_link("Switch app")
      end
    end
  end

  context "as a GDS Editor" do
    before { login_as_gds_editor }

    it "shows all four menu options" do
      visit "/"

      within(".govuk-service-navigation__container") do
        expect(page).to have_link("Broken Links")
        expect(page).to have_link("Councils")
        expect(page).to have_link("Services")
        expect(page).to have_link("Switch app")
      end
    end
  end
end
