feature "The local authority show page" do
  let!(:local_authority) { create(:district_council) }

  before do
    User.create!(email: "user@example.com", name: "Test User", permissions: %w[signin])
    visit local_authority_path(local_authority_slug: local_authority.slug)
  end

  it "has a list of breadcrumbs pointing back to the authority that lead us here" do
    within ".breadcrumb" do
      expect(page).to have_link "Local links", href: root_path
      expect(page).to have_text local_authority.name
    end
  end

  describe "editing the homepage URL" do
    it "has an edit field for the homepage URL" do
      expect(page).to have_field("Homepage URL", with: local_authority.homepage_url)
    end

    it "updates the homepage URL" do
      fill_in "Homepage URL", with: "https://new.root.gov.uk"
      click_on "Update"
      expect(page).to have_link "Visit https://new.root.gov.uk", href: "https://new.root.gov.uk"
    end
  end

  describe "with no local authority homepage url" do
    it "renders the local authority services page successfully" do
      ni_local_authority = create(:district_council)
      visit local_authority_path(local_authority_slug: ni_local_authority.slug)
      expect(page.status_code).to eq(200)

      within(:css, ".page-title") do
        expect(page).not_to have_link("/local_authorities/#{ni_local_authority.slug}/services")
      end
    end

    it "displays 'No link'" do
      local_authority.homepage_url = nil
      local_authority.save!
      visit local_authority_path(local_authority_slug: local_authority.slug)
      within(:css, ".page-title") do
        expect(page).to have_content("No link")
      end
    end

    it "does not display 'Link not checked'" do
      local_authority.homepage_url = nil
      local_authority.save!
      visit local_authority_path(local_authority_slug: local_authority.slug)
      within(:css, ".page-title") do
        expect(page).not_to have_content("Link not checked")
      end
    end
  end

  describe "with services present" do
    let(:service) { create(:service, :all_tiers) }
    let(:disabled_service) { create(:disabled_service) }
    let!(:ok_link) { create_service_interaction_link(service, status: :ok) }
    let!(:disabled_link) { create_service_interaction_link(disabled_service, status: :ok) }
    let!(:broken_link) { create_service_interaction_link(service, status: :broken) }
    let!(:missing_link) { create_missing_link(service) }

    before do
      visit local_authority_path(local_authority)
    end

    let(:http_status) { 200 }

    it "shows a count of the number of all links for enabled services" do
      within("thead") do
        expect(page).to have_content "3 links"
      end
    end

    it "displays a filter box" do
      expect(page).to have_selector(".filter-control")
    end

    it "has navigation tabs" do
      expect(page).to have_selector(".link-nav")
      within(".link-nav") do
        expect(page).to have_link "Broken links"
        expect(page).to have_link "All links"
      end
    end

    it "shows only the enabled services provided by the authority according to its tier with links to their individual pages" do
      expect(page).to have_content "Services and links"
      expect(page).to have_text(ok_link.service.label)
    end

    it "does not show the disabled service interaction" do
      expect(page).not_to have_content(disabled_service.label)
    end

    it "shows missing links" do
      expect(page).to have_content("Missing")
    end

    it "shows each service's LGSL codes in the table" do
      expect(page).to have_content "Code"
      expect(page).to have_css("td.lgsl", text: ok_link.service.lgsl_code)
    end

    it "shows the link status as Good Link when the status is 200" do
      within(:css, "tr[data-interaction-id=\"#{ok_link.interaction.id}\"]") do
        expect(page).to have_text "Good"
      end
    end

    it "shows the link last checked details" do
      within(:css, "tr[data-interaction-id=\"#{ok_link.interaction.id}\"]") do
        expect(page).to have_text "Link not checked"
      end
    end

    it "should have a link to Edit Link" do
      expect(page).to have_link "Edit link", href: edit_link_path(local_authority, service, ok_link.interaction)
    end

    describe "CSV download" do
      let(:status_checkboxes) { %w[ok broken caution missing pending] }
      let(:url_regex) { /http:\/\/.+\/local_authorities\/.+\/download_links_csv/ }

      it "downloads a CSV" do
        click_on "Download links"

        expect(page.response_headers["Content-Type"]).to eq("text/csv")
      end

      context "when user leaves all link status checkboxes selected (by default)", js: true do
        it "passes all statuses in params" do
          submit_button = find("a", text: "Download links")
          params = submit_button["href"].split("?")[-1].split("&")

          expect(submit_button["href"]).to match(url_regex)
          status_checkboxes.each do |status|
            expect(params).to include("#{status}=#{status}")
          end
        end
      end

      context "when user deselects some link status checkboxes", js: true do
        let(:unchecked_status_checkboxes) { %w[ok caution pending] }
        let(:checked_status_checkboxes) { status_checkboxes - unchecked_status_checkboxes }

        it "passes all statuses in params, except the unchecked ones" do
          submit_button = find("a", text: "Download links")
          expect(submit_button["href"]).to match(url_regex)

          unchecked_status_checkboxes.each { |status_checkbox| uncheck status_checkbox }
          params = submit_button["href"].split("?")[-1].split("&")

          checked_status_checkboxes.each do |status|
            expect(params).to include("#{status}=#{status}")
          end

          unchecked_status_checkboxes.each do |status|
            expect(params).to_not include("#{status}=#{status}")
          end
        end
      end
    end

    context "editing a link" do
      it "returns you to the correct page after updating a link" do
        within(".table") { click_on("Edit link", match: :first) }
        fill_in("link_url", with: "http://angus.example.com/link-to-change")
        click_on("Update")

        expect(page.current_path).to eq(local_authority_path(local_authority))
      end

      it "returns you to the correct page after cancelling the editing of a link" do
        within(".table") { click_on("Edit link", match: :first) }
        click_on("Cancel")

        expect(page.current_path).to eq(local_authority_path(local_authority))
      end
    end

    it "shows the status of broken links" do
      expect(page).to have_text "Broken"
    end

    describe "broken links" do
      before do
        click_link "Broken links"
      end

      it "shows non-200 status links" do
        expect(page).to have_link broken_link.url
      end

      it "doesn't show 200 status links" do
        expect(page).not_to have_link ok_link.url
      end

      it "shows missing links" do
        expect(page).to have_content("Missing")
      end
    end
  end

  def create_service_interaction_link(service, status:)
    service_interaction = create(:service_interaction, service: service)

    create(
      :link,
      local_authority: local_authority,
      service_interaction: service_interaction,
      status: status,
    )
  end

  def create_missing_link(service)
    service_interaction = create(:service_interaction, service: service)

    create(
      :missing_link,
      local_authority: local_authority,
      service_interaction: service_interaction,
      status: "missing",
    )
  end
end
