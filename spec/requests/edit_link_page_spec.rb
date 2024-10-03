RSpec.describe "Edit link page" do
  let(:owning_department) { "department-of-aardvarks" }
  let!(:service) { create(:service, label: "Aardvark Wardens", organisation_slugs: [owning_department]) }
  let!(:interaction) { create(:interaction, label: "reporting") }
  let!(:service_interaction) { create(:service_interaction, service:, interaction:) }
  let!(:local_authority) { create(:district_council, slug: "north-midlands") }
  let!(:link) { create(:link, local_authority:, service_interaction:) }

  describe "GET /local_authorities/:local_authority_slug/services/:service_slug/:interaction_slug/edit" do
    it_behaves_like "it is forbidden to non-owners", "/local_authorities/north-midlands/services/aardvark-wardens/reporting/edit", "department-of-aardvarks"
  end

  describe "PUT /local_authorities/:local_authority_slug/services/:service_slug/:interaction_slug" do
    let(:path) { "/local_authorities/north-midlands/services/aardvark-wardens/reporting" }
    let(:url) { "http://www.example.com/new" }

    context "as a GDS Editor" do
      before { login_as_gds_editor }

      it "returns 302 Found" do
        put path, params: { url: }

        expect(response).to have_http_status(:found)
      end

      it "updates the link" do
        put path, params: { url: }

        expect(Link.last.url).to eq("http://www.example.com/new")
        expect(flash[:danger]).to be nil
        expect(link.reload.url).to eq(url)
      end

      it "catches invalid links" do
        put path, params: { url: "ftp://who" }

        expect(response).to have_http_status(:found)
        expect(flash[:danger]).not_to be nil
      end
    end

    context "as a department user from the owning department" do
      before { login_as_department_user(organisation_slug: owning_department) }

      it "returns 302 Found" do
        put path, params: { url: }

        expect(response).to have_http_status(:found)
      end

      it "updates the link" do
        put path, params: { url: }

        expect(link.reload.url).to eq(url)
      end
    end

    context "as a department user" do
      before { login_as_department_user }

      it "returns 403 Forbidden" do
        put path, params: { url: }

        expect(response).to have_http_status(:forbidden)
      end

      it "does not update the link" do
        original_link = link.url
        put path, params: { url: }

        expect(link.reload.url).to eq(original_link)
      end
    end
  end

  describe "DELETE /local_authorities/:local_authority_slug/services/:service_slug/:interaction_slug" do
    let(:path) { "/local_authorities/north-midlands/services/aardvark-wardens/reporting" }

    context "as a GDS Editor" do
      before { login_as_gds_editor }

      it "returns 302 Found" do
        delete path

        expect(response).to have_http_status(:found)
      end
    end

    context "as a department user from the owning department" do
      before { login_as_department_user(organisation_slug: owning_department) }

      it "returns 403 Forbidden" do
        delete path

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "as a department user" do
      before { login_as_department_user }

      it "returns 403 Forbidden" do
        delete path

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
