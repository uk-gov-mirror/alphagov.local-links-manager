RSpec.describe "Edit link page" do
  let(:owning_department) { "department-of-aardvarks" }
  let!(:service) { create(:service, label: "Aardvark Wardens", organisation_slugs: [owning_department]) }
  let!(:interaction) { create(:interaction, label: "reporting") }
  let!(:service_interaction) { create(:service_interaction, service:, interaction:) }
  let!(:local_authority) { create(:district_council, slug: "north-midlands") }
  let!(:link) { create(:link, local_authority:, service_interaction:) }

  context "as an owning user" do
    before { login_as_department_user(organisation_slug: owning_department) }

    it "doesn't show the delete link" do
      visit "/local_authorities/north-midlands/services/aardvark-wardens/reporting/edit"

      expect(page).not_to have_button("Delete")
    end
  end

  context "as a GDS Editor" do
    before { login_as_gds_editor }

    it "shows the delete link" do
      visit "/local_authorities/north-midlands/services/aardvark-wardens/reporting/edit"

      expect(page).to have_button("Delete")
      click_on "Delete"
      expect(page).to have_content("Link has been deleted")
    end
  end
end
