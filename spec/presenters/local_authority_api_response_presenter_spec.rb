describe LocalAuthorityApiResponsePresenter do
  describe '#present' do
    context 'when the local authority has a parent' do
      let(:parent_local_authority) { build(:county_council) }
      let(:authority) { build(:district_council, parent_local_authority: parent_local_authority) }
      let(:presenter) { described_class.new(authority) }
      let(:expected_response) do
        {
          "local_authorities" => [
            {
              "name" => authority.name,
              "homepage_url" => authority.homepage_url,
              "tier" => 'district'
            },
            {
              "name" => parent_local_authority.name,
              "homepage_url" => parent_local_authority.homepage_url,
              "tier" => 'county'
            }
          ]
        }
      end
      it "returns a json with the authority's details and its parent authority details" do
        expect(presenter.present).to eq(expected_response)
      end
    end

    context 'when local authority does not have a parent' do
      let(:authority) { build(:unitary_council) }
      let(:presenter) { described_class.new(authority) }
      let(:expected_response) do
        {
          "local_authorities" => [
            {
              "name" => authority.name,
              "homepage_url" => authority.homepage_url,
              "tier" => 'unitary'
            }
          ]
        }
      end

      it "returns a json response with unitary local authority details" do
        expect(presenter.present).to eq(expected_response)
      end
    end
  end
end
