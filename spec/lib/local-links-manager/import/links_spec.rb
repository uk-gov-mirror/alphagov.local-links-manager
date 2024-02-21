RSpec.describe LocalLinksManager::Import::Links do
  let(:local_authority) { create(:local_authority) }
  subject(:links_importer) { described_class.new(type: :local_authority, object: local_authority) }
  let(:ok_link) { create(:ok_link, local_authority:) }
  let(:broken_link) { create(:broken_link, local_authority:) }
  let(:caution_link) { create(:caution_link, local_authority:) }
  let(:missing_link) { create(:missing_link, local_authority:) }
  let(:pending_link) { create(:pending_link, local_authority:) }
  let(:links) { [ok_link, broken_link, caution_link, missing_link, pending_link] }
  let!(:csv) { create_csv(local_authority, links, new_url) }

  describe "#import_links(csv)" do
    context "when a new URL is provided" do
      let(:new_url) { "http://example.com/new-url" }

      it "updates the existing links with the new URLs" do
        old_urls = links.map(&:url)

        expect { links_importer.import_links(csv) }
          .to change { links.map(&:reload).map(&:url) }
          .from(old_urls)
          .to([new_url] * links.count)
      end

      it "returns the number of updated links" do
        links_count = csv.split("\n").count - 1 # the number of rows minus the headings

        expect(links_importer.import_links(csv)).to eq(links_count)
      end
    end

    context "when a new URL is provided but isn't valid" do
      let(:new_url) { "closed" }

      it "does not update the existing link" do
        expect { links_importer.import_links(csv) }.to_not(change { links.map(&:reload).map(&:url) })
      end

      it "logs to the Rails logger (for surfacing in Kibana)" do
        line = /Validation failed: Url \(#{new_url}\) is not a URL/
        debug_info = /\({:local_authority_slug=>"local-authority-name-\d+", :service_slug=>"all-tiers-\d+", :interaction_slug=>"interaction-label-\d+", :link_id=>\d+}\)/
        expect(Rails.logger).to receive(:warn)
          .with(/^#{line} #{debug_info}$/)
          .exactly(5).times
        links_importer.import_links(csv)
      end

      it "returns an informative error to the user" do
        links_importer.import_links(csv)
        expect(links_importer.errors).to eq([
          "Line 2: invalid URL '#{new_url}'",
          "Line 3: invalid URL '#{new_url}'",
          "Line 4: invalid URL '#{new_url}'",
          "Line 5: invalid URL '#{new_url}'",
          "Line 6: invalid URL '#{new_url}'",
        ])
      end
    end

    context "when no new URL is provided" do
      let(:new_url) { nil }

      it "does not update the existing links" do
        expect { links_importer.import_links(csv) }.to_not(change { links.map(&:reload).map(&:url) })
      end

      it "returns the number of updated links" do
        expect(links_importer.import_links(csv)).to eq(0)
      end
    end
  end

  def create_csv(local_authority, links, new_url)
    links_as_csv_rows = links.map do |link|
      "blah,blah,#{local_authority.gss},blah,#{link.service.lgsl_code},#{link.interaction.lgil_code},blah,blah,blah,#{new_url}"
    end
    <<~CSV
      Authority Name,SNAC,GSS,Description,LGSL,LGIL,URL,Supported by GOV.UK,Status,New URL
      #{links_as_csv_rows.join("\n")}
    CSV
  end
end
