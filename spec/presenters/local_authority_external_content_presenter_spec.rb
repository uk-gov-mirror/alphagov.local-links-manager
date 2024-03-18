describe LocalAuthorityExternalContentPresenter do
  describe "#present_for_publishing_api" do
    let(:authority) { build(:county_council, name: "Angus County Council") }
    let(:presenter) { described_class.new(authority) }
    let(:expected_response) do
      {
        description: "Website of Angus County Council",
        details: {
          url: "http://www.angus.gov.uk",
        },
        document_type: "external_content",
        publishing_app: "local-links-manager",
        schema_name: "external_content",
        title: "Angus County Council",
        update_type: "minor",
      }
    end

    it "returns a hash appropriate for an external content item in the Publishing API" do
      expect(presenter.present_for_publishing_api).to eq(expected_response)
    end
  end
end
