shared_examples_for "link path" do
  let!(:local_authority) do
    create(
      :unitary_council,
      name: "Blackburn",
      slug: "blackburn",
      homepage_url: "http://blackburn.example.com",
      country_name: "England",
      snac: "00AG",
      gss: "E09000007",
      local_custodian_code: "2372",
    )
  end

  let!(:service) { create(:service, label: "abandoned-shopping-trolleys", lgsl_code: 2) }

  let(:interaction) { create(:interaction, label: "report", lgil_code: 4) }

  let(:service_interaction) { create(:service_interaction, service:, interaction:) }

  let(:local_authority_response) do
    {
      "local_authority" => {
        "name" => "Blackburn",
        "snac" => "00AG",
        "gss" => "E09000007",
        "tier" => "unitary",
        "homepage_url" => "http://blackburn.example.com",
        "country_name" => "England",
        "slug" => "blackburn",
      },
    }
  end

  let(:link_response) do
    {
      "local_interaction" => {
        "lgsl_code" => 2,
        "lgil_code" => 4,
        "url" => "http://blackburn.example.com/abandoned-shopping-trolleys/report",
        "status" => "ok",
        "title" => nil,
      },
    }
  end

  let(:expected_response) { local_authority_response.merge(link_response) }
  let(:expected_response_with_no_link) { local_authority_response }

  context "for a request with authority slug, lgsl and lgil params" do
    let!(:link) { create(:link, local_authority:, service_interaction:, url: "http://blackburn.example.com/abandoned-shopping-trolleys/report", status: "ok") }

    it "responds with LocalAuthority and Link details" do
      get "/api/link?#{authority_search}&lgsl=2&lgil=4"

      expect(response.status).to eq(200)
      expect(response.parsed_body).to eq(expected_response)
    end

    it "responds without link details if Link not present for LGIL" do
      interaction = create(:interaction, lgil_code: 5)
      create(:service_interaction, service:, interaction:)
      get "/api/link?#{authority_search}&lgsl=2&lgil=5"

      expect(response.status).to eq(200)
      expect(response.parsed_body).to eq(expected_response_with_no_link)
    end

    it "responds without link details if Link url is nil" do
      interaction = create(:interaction, lgil_code: 6)
      service_interaction = create(:service_interaction, service:, interaction:)
      create(:missing_link, local_authority:, service_interaction:)

      get "/api/link?#{authority_search}&lgsl=2&lgil=6"

      expect(response.status).to eq(200)
      expect(response.parsed_body).to eq(expected_response_with_no_link)
    end

    it "responds with 404 and {} for unsupported local_authority" do
      get "/api/link?#{authority_search_bad_value}s&lgsl=2&lgil=4"

      expect(response.status).to eq(404)
      expect(response.parsed_body).to eq({})
    end

    it "responds with 404 and {} for unsupported lgsl" do
      get "/api/link?#{authority_search}&lgsl=99&lgil=4"

      expect(response.status).to eq(404)
      expect(response.parsed_body).to eq({})
    end

    it "responds without link details for unsupported lgsl and lgil combination" do
      link.destroy!
      service_interaction.destroy!

      get "/api/link?#{authority_search}&lgsl=2&lgil=4"

      expect(response.status).to eq(200)
      expect(response.parsed_body).to eq(expected_response_with_no_link)
    end
  end

  context "for a request with authority slug and lgsl params" do
    context "when LGILs exist" do
      it "responds with Link details for the lowest LGIL" do
        expected_response = {
          "local_authority" => {
            "name" => "Blackburn",
            "snac" => "00AG",
            "gss" => "E09000007",
            "tier" => "unitary",
            "homepage_url" => "http://blackburn.example.com",
            "country_name" => "England",
            "slug" => "blackburn",
          },
          "local_interaction" => {
            "lgsl_code" => 2,
            "lgil_code" => 1,
            "url" => "http://blackburn.example.com/abandoned-shopping-trolleys/report",
            "status" => nil,
            "title" => nil,
          },
        }

        interaction1 = create(:interaction, label: "report", lgil_code: 1)
        interaction2 = create(:interaction, label: "appeal", lgil_code: 2)
        service_interaction1 = create(:service_interaction, service:, interaction: interaction1)
        service_interaction2 = create(:service_interaction, service:, interaction: interaction2)
        create(:link, local_authority:, service_interaction: service_interaction1, url: "http://blackburn.example.com/abandoned-shopping-trolleys/report")
        create(:link, local_authority:, service_interaction: service_interaction2, url: "http://blackburn.example.com/abandoned-shopping-trolleys/appeal", status: nil)

        get "/api/link?#{authority_search}&lgsl=2"

        expect(response.status).to eq(200)
        expect(response.parsed_body).to eq(expected_response)
      end

      it "does not respond with LGIL 8 even if it is the lowest" do
        expected_response = {
          "local_authority" => {
            "name" => "Blackburn",
            "snac" => "00AG",
            "gss" => "E09000007",
            "tier" => "unitary",
            "homepage_url" => "http://blackburn.example.com",
            "country_name" => "England",
            "slug" => "blackburn",
          },
          "local_interaction" => {
            "lgsl_code" => 2,
            "lgil_code" => 9,
            "url" => "http://blackburn.example.com/abandoned-shopping-trolleys/regulation",
            "status" => nil,
            "title" => nil,
          },
        }

        interaction1 = create(:interaction, label: "providing_information", lgil_code: 8)
        interaction2 = create(:interaction, label: "regulation", lgil_code: 9)
        service_interaction1 = create(:service_interaction, service:, interaction: interaction1)
        service_interaction2 = create(:service_interaction, service:, interaction: interaction2)
        create(:link, local_authority:, service_interaction: service_interaction1, url: "http://blackburn.example.com/abandoned-shopping-trolleys/regulation")
        create(:link, local_authority:, service_interaction: service_interaction2, url: "http://blackburn.example.com/abandoned-shopping-trolleys/regulation", status: nil)

        get "/api/link?#{authority_search}&lgsl=2"

        expect(response.status).to eq(200)
        expect(response.parsed_body).to eq(expected_response)
      end
    end

    context "the only LGIL that exists is LGIL 8" do
      it "responds with Link details for the LGIL 8" do
        expected_response = {
          "local_authority" => {
            "name" => "Blackburn",
            "snac" => "00AG",
            "gss" => "E09000007",
            "tier" => "unitary",
            "homepage_url" => "http://blackburn.example.com",
            "country_name" => "England",
            "slug" => "blackburn",
          },
          "local_interaction" => {
            "lgsl_code" => 2,
            "lgil_code" => 8,
            "url" => "http://blackburn.example.com/abandoned-shopping-trolleys/providing_information",
            "status" => "ok",
            "title" => nil,
          },
        }

        interaction = create(:interaction, label: "providing_information", lgil_code: 8)
        service_interaction = create(:service_interaction, service:, interaction:)
        create(:link, local_authority:, service_interaction:, url: "http://blackburn.example.com/abandoned-shopping-trolleys/providing_information", status: "ok")

        get "/api/link?#{authority_search}&lgsl=2"

        expect(response.status).to eq(200)
        expect(response.parsed_body).to eq(expected_response)
      end
    end

    context "no LGIL links exist" do
      it "responds with no link details" do
        expected_response = {
          "local_authority" => {
            "name" => "Blackburn",
            "snac" => "00AG",
            "gss" => "E09000007",
            "tier" => "unitary",
            "homepage_url" => "http://blackburn.example.com",
            "country_name" => "England",
            "slug" => "blackburn",
          },
        }
        get "/api/link?#{authority_search}&lgsl=2"

        expect(response.status).to eq(200)
        expect(response.parsed_body).to eq(expected_response)
      end
    end

    it "responds with 404 and {} for unsupported local_authority" do
      get "/api/link?#{authority_search_bad_value}&lgsl=2"

      expect(response.status).to eq(404)
      expect(response.parsed_body).to eq({})
    end

    it "responds with 404 and {} for unsupported lgsl" do
      get "/api/link?#{authority_search}&lgsl=99"

      expect(response.status).to eq(404)
      expect(response.parsed_body).to eq({})
    end
  end

  context "for a request with missing mandatory query parameters" do
    it "responds with 400 and {} for missing authority_slug param" do
      get "/api/link?lgsl=2"

      expect(response.status).to eq(400)
      expect(response.parsed_body).to eq({})
    end

    it "responds with 400 and {} if both authority_slug and local_custodian_code params provided" do
      get "/api/link?authority_slug=blackburn&local_custodian_code=2372&lgsl=2"

      expect(response.status).to eq(400)
      expect(response.parsed_body).to eq({})
    end

    it "responds with 400 and {} for missing lgsl param" do
      get "/api/link?#{authority_search}"

      expect(response.status).to eq(400)
      expect(response.parsed_body).to eq({})
    end
  end
end

RSpec.describe "link path (search by authority slug)", type: :request do
  let(:authority_search) { "authority_slug=blackburn" }
  let(:authority_search_bad_value) { "authority_slug=hogwarts" }

  it_behaves_like "link path"
end

RSpec.describe "link path (search by local custodian code)", type: :request do
  let(:authority_search) { "local_custodian_code=2372" }
  let(:authority_search_bad_value) { "local_custodian_code=99999" }

  it_behaves_like "link path"
end
