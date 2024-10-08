RSpec.describe "Council page" do
  let!(:local_authority) { create(:district_council, slug: "north-midlands", gss: "S1") }
  let(:fixture_path) { "spec/lib/local-links-manager/import/fixtures/" }

  context "with errors in the CSV" do
    before do
      login_as_gds_editor
      interaction = create(:interaction, lgil_code: 1)
      6.times do |i|
        service = create(:service, lgsl_code: i + 1)
        create(:service_interaction, service:, interaction:)
      end
    end

    it "shows the all error message if all lines are broken" do
      visit "/local_authorities/north-midlands/upload_links_form"

      attach_file(Rails.root.join(fixture_path, "imported_links_all_errors.csv"))
      expect(page).to have_button("Upload Links")
      click_button "Upload Links"

      expect(page).to have_content("Errors on all lines. Ensure a New URL column exists, with all rows either blank or a valid URL")
    end

    it "shows the many error message if many lines are broken" do
      visit "/local_authorities/north-midlands/upload_links_form"

      attach_file(Rails.root.join(fixture_path, "imported_links_many_errors.csv"))
      expect(page).to have_button("Upload Links")
      click_button "Upload Links"
      expect(page).to have_content("74 Errors detected. Please ensure a valid entry in the New URL column for lines (showing first 50):")
    end

    it "shows the few error message if few lines are broken" do
      visit "/local_authorities/north-midlands/upload_links_form"

      attach_file(Rails.root.join(fixture_path, "imported_links_few_errors.csv"))
      expect(page).to have_button("Upload Links")
      click_button "Upload Links"
      expect(page).to have_content("2 Errors detected. Please ensure a valid entry in the New URL column for lines:")
    end

    it "shows the nothing to import info if it didn't import anything" do
      visit "/local_authorities/north-midlands/upload_links_form"

      attach_file(Rails.root.join(fixture_path, "imported_links_nothing_to_import.csv"))
      expect(page).to have_button("Upload Links")
      click_button "Upload Links"
      expect(page).to have_content("No records updated. (If you were expecting updates, check the format of the uploaded file)")
    end
  end
end
