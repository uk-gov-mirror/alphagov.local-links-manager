require "rails_helper"

RSpec.describe LocalAuthorityRedirector do
  include GdsApi::TestHelpers::PublishingApiV2

  let(:old_local_authority) { create(:county_council, slug: "old") }
  let(:new_local_authority) { create(:county_council, slug: "new") }

  subject(:call) do
    described_class.call(from: old_local_authority, to: new_local_authority)
  end

  context "given the old local authority has more services than the new one" do
    let(:new_local_authority) { create(:district_council) }

    before do
      create(:service, :all_tiers)
      create(:service, :county_unitary)
    end

    it "should raise an exception" do
      expect { call }.to raise_error(/has some services that/)
    end
  end

  context "given a service exists" do
    let(:service) { create(:service, :all_tiers) }

    let(:content_id) { "dfdb939f-1c0e-4223-81ef-3a8556540ca9" }

    before do
      create(:service_interaction, service: service, govuk_slug: "interaction")
      allow(SecureRandom).to receive(:uuid).and_return(content_id)
    end

    let!(:put_content_request) do
      body = {
        "base_path": "/interaction/old",
        "document_type": "redirect",
        "schema_name": "redirect",
        "publishing_app": "local-links-manager",
        "update_type": "major",
        "redirects": [
          {
            "path": "/interaction/old",
            "type": "exact",
            "segments_mode": "ignore",
            "destination": "/interaction/new",
          },
        ],
      }
      stub_publishing_api_put_content(content_id, body)
    end

    let!(:publish_request) { stub_publishing_api_publish(content_id, {}) }

    it "creates a redirect" do
      call

      expect(put_content_request).to have_been_requested
      expect(publish_request).to have_been_requested
    end
  end
end
