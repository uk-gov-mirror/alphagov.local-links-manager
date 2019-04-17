require "rails_helper"
require "local-links-manager/import/links"

RSpec.describe LocalLinksManager::Import::Links do
  let!(:local_authority) { FactoryBot.create(:local_authority) }
  let!(:link) { FactoryBot.create(:ok_link) }

  subject { described_class.new(local_authority) }

  let(:new_url) { "http://example.com/new-url" }
  let(:csv_string) {
    csv(
      lgsl: link.service.lgsl_code,
      lgil: link.interaction.lgil_code,
      new_url: new_url,
    )
  }

  describe "#import_links(csv_string)" do
    it "updates the existing link with the new URL" do
      subject.import_links(csv_string)
      expect(link.reload.url).to eq(new_url)
    end

    it "returns the number of updated links" do
      updated_count = subject.import_links(csv_string)
      expect(updated_count).to eq(1)
    end

    context "for missing links" do
      let!(:link) { FactoryBot.create(:missing_link) }

      it "replaces the missing link with the new URL" do
        subject.import_links(csv_string)
        expect(link.reload.url).to eq(new_url)
      end
    end

    context "if no new URL is provided" do
      let!(:link) { FactoryBot.create(:ok_link) }
      let(:new_url) { nil }

      it "does nothing" do
        link_url = link.url
        updated_count = subject.import_links(csv_string)

        expect(link.reload.url).to eq(link_url)
        expect(updated_count).to eq(0)
      end
    end
  end

  def csv(lgsl:, lgil:, new_url:)
    <<~CSV
    Authority Name,SNAC,GSS,Description,LGSL,LGIL,URL,Supported by GOV.UK,Status,New URL
    blah,blah,blah,blah,#{lgsl},#{lgil},blah,blah,blah,#{new_url}
    CSV
  end
end
