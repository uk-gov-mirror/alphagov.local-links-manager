require 'rails_helper'

RSpec.describe "find local authority", type: :request do
  context "for councils that have a parent authority" do
    let(:parent_local_authority) do
      create(:county_council,
             name: 'Rochester',
             slug: 'rochester',
             homepage_url: "http://rochester.example.com")
    end
    let!(:local_authority) do
      create(:district_council,
             name: 'Blackburn',
             slug: 'blackburn',
             homepage_url: "http://blackburn.example.com",
             parent_local_authority: parent_local_authority)
    end

    let(:expected_response) do
      {
        "local_authorities" => [
          {
            "name" => 'Blackburn',
            "homepage_url" => "http://blackburn.example.com",
            "tier" => "district"
          },
          {
            "name" => 'Rochester',
            "homepage_url" => "http://rochester.example.com",
            "tier" => "county"
          }
        ]
      }
    end

    it 'returns details of the child and parent in the api response' do
      get '/api/local-authority?authority_slug=blackburn'

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq(expected_response)
    end
  end

  context "for councils that do not have a parent authority" do
    let!(:local_authority) do
      create(:unitary_council,
             name: 'Blackburn',
             slug: 'blackburn',
             homepage_url: "http://blackburn.example.com")
    end

    let(:expected_response) do
      {
        "local_authorities" => [
          {
            "name" => 'Blackburn',
            "homepage_url" => "http://blackburn.example.com",
            "tier" => "unitary"
          }
        ]
      }
    end

    it 'returns details of the council in the api response' do
      get '/api/local-authority?authority_slug=blackburn'

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq(expected_response)
    end
  end

  context "for requests with missing parameters" do
    it "returns a 400 status" do
      get '/api/local-authority'

      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)).to eq({})
    end
  end

  context "for requests with parameters that do not refer to data" do
    it "returns a 404 status" do
      get '/api/local-authority?authority_slug=foobar'

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)).to eq({})
    end
  end
end
