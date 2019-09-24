describe InteractionPresenter do
  let(:interaction) { create(:interaction) }
  let(:presented_link) { double(:LinkPresenter, url: "http://example.com", status_description: "Good", last_checked: "2016-07-19 16:37:41 +0000", label_status_class: "label-success") }
  let(:presenter_with_link) { InteractionPresenter.new(interaction, presented_link) }
  let(:presenter_without_link) { InteractionPresenter.new(interaction) }

  describe "#link_url" do
    it "returns a link URL if there is a link present" do
      expect(presenter_with_link.link_url).to eq("http://example.com")
    end

    it "returns nil if there is no link present" do
      expect(presenter_without_link.link_url).to be_nil
    end
  end

  describe "#link_status" do
    it "returns the link's status description if a link is present" do
      expect(presenter_with_link.link_status).to eq("Good")
    end

    it 'returns "No link" if there is no link present' do
      expect(presenter_without_link.link_status).to eq("No link")
    end
  end

  describe "#link_last_checked" do
    it "returns the time that the link was last checked if a link is present" do
      expect(presenter_with_link.link_last_checked).to eq("2016-07-19 16:37:41 +0000")
    end

    it "returns an empty string if there is no link present" do
      expect(presenter_without_link.link_last_checked).to eq("")
    end
  end

  describe "#button_text" do
    it 'returns "Edit link" if a link is present' do
      expect(presenter_with_link.button_text).to eq("Edit link")
    end

    it 'returns "Add link" if there is no link present' do
      expect(presenter_without_link.button_text).to eq("Add link")
    end
  end

  describe "#label_status_class" do
    it 'returns "label-success" if there is a link present and its status is "200"' do
      expect(presenter_with_link.label_status_class).to eq("label-success")
    end

    it "returns an empty string if there is no link present" do
      expect(presenter_without_link.label_status_class).to eq("")
    end
  end
end
