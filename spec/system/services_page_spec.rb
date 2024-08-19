require "gds_api/test_helpers/organisations"

RSpec.describe "Services page" do
  include GdsApi::TestHelpers::Organisations

  before do
    create(:service, label: "Aardvark Wardens", organisation_slugs: %w[department-of-aardvarks])
  end

  context "as a gds editor" do
    before { login_as_gds_editor }

    it "shows all the services" do
      visit "/services"

      expect(page).to have_content("Aardvark Wardens")
    end

    it "shows a generic title" do
      visit "/services"

      expect(page).to have_content("Services (1)")
    end
  end

  context "as a department user" do
    before do
      stub_organisations_api_has_organisations_with_bodies([{ "title" => "Department of Randomness", "details" => { "slug" => "random-department" } }])
      login_as_department_user
    end

    it "does not show Aardvark Wardens service" do
      visit "/services"

      expect(page).not_to have_content("Aardvark Wardens")
    end

    it "shows a department title" do
      visit "/services"

      expect(page).to have_content("Services for Department of Randomness (0)")
    end

    context "if the Organisations API fails" do
      before do
        stub_request(:get, "#{Plek.new.website_root}/api/organisations/random-department").to_raise(GdsApi::HTTPUnavailable)
      end

      it "shows a generic title" do
        visit "/services"

        expect(page).to have_content("Services for random-department (0)")
      end
    end
  end

  context "as a user from an owning department" do
    before do
      stub_organisations_api_has_organisations_with_bodies([{ "title" => "Department of Aardvarks", "details" => { "slug" => "department-of-aardvarks" } }])
      login_as_department_user(organisation_slug: "department-of-aardvarks")
    end

    before { login_as_department_user(organisation_slug: "department-of-aardvarks") }

    it "shows the related services only" do
      visit "/services"

      expect(page).to have_content("Aardvark Wardens")
    end

    it "shows a department title" do
      visit "/services"

      expect(page).to have_content("Services for Department of Aardvarks (1)")
    end
  end
end
