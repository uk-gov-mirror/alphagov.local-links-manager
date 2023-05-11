describe LocalAuthorityApiResponsePresenter do
  describe "#to_h" do
    context "when the authority has a SNAC" do
      let(:authority) { build(:district_council) }
      let(:presenter) { described_class.new(authority) }
      let(:expected_response) do
        {
          "local_authorities" => [
            {
              "name" => authority.name,
              "homepage_url" => authority.homepage_url,
              "country_name" => authority.country_name,
              "tier" => "district",
              "slug" => authority.slug,
              "snac" => authority.snac,
              "gss" => authority.gss,
            },
          ],
        }
      end

      it "returns a json with both GSS and SNAC codes" do
        expect(presenter.present).to eq(expected_response)
      end
    end

    context "when the authority does not have a SNAC" do
      let(:authority) { build(:district_council, snac: nil) }
      let(:presenter) { described_class.new(authority) }
      let(:expected_response) do
        {
          "local_authorities" => [
            {
              "name" => authority.name,
              "homepage_url" => authority.homepage_url,
              "country_name" => authority.country_name,
              "tier" => "district",
              "slug" => authority.slug,
              "gss" => authority.gss,
            },
          ],
        }
      end

      it "returns a json with GSS but no SNAC code" do
        expect(presenter.present).to eq(expected_response)
      end
    end
  end
end
