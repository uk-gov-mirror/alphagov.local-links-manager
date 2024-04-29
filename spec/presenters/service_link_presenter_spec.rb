describe ServiceLinkPresenter do
  let(:link) { double(:link, local_authority: double(id: 1), service: double(id: 2), interaction: double(id: 3), url: "url") }
  let(:view_context) { double(:view_context, edit_link_path: "path") }
  let(:first) { double(:first) }
  let(:presenter) { ServiceLinkPresenter.new(link, view_context:, first:) }

  describe "#initialize" do
    it "initializes with correct attributes" do
      expect(presenter.view_context).to eq(view_context)
      expect(presenter.first).to eq(first)
    end
  end

  describe "#row_data" do
    it "returns correct data" do
      expected_data = {
        local_authority_id: 1,
        service_id: 2,
        interaction_id: 3,
        url: "url",
      }

      expect(presenter.row_data).to eq(expected_data)
    end
  end

  describe "#edit_path" do
    it "returns correct path" do
      expect(presenter.edit_path).to eq("path")
    end
  end
end
