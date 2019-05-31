require "local-links-manager/check_links/link_status_requester"
require "gds_api/test_helpers/link_checker_api"

describe LocalLinksManager::CheckLinks::LinkStatusRequester do
  include GdsApi::TestHelpers::LinkCheckerApi

  subject(:link_status_requester) { described_class.new }

  context "with homepage URLs and links for enabled services" do
    let(:local_authority_1) { create(:local_authority, homepage_url: "https://www.ambridge.gov.uk") }
    let(:local_authority_2) { create(:local_authority, homepage_url: "https://www.midsomer.gov.uk") }
    let!(:link_1) { create(:link, local_authority: local_authority_1, url: 'http://www.example.com/example1.html') }
    let!(:link_2) { create(:link, local_authority: local_authority_2, url: 'http://www.example.com/example2.html') }
    let!(:missing_link) { create(:missing_link, local_authority: local_authority_1) }

    it "makes batch requests to the link checker API not including missing links" do
      stub_1 = link_checker_api_create_batch(
        uris: [link_1.url],
        webhook_uri: "http://local-links-manager.dev.gov.uk/link-check-callback",
        webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token,
      )

      stub_2 = link_checker_api_create_batch(
        uris: [link_2.url],
        webhook_uri: "http://local-links-manager.dev.gov.uk/link-check-callback",
        webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token,
      )

      stub_3 = link_checker_api_create_batch(
        uris: [local_authority_1.homepage_url, local_authority_2.homepage_url],
        webhook_uri: "http://local-links-manager.dev.gov.uk/link-check-callback",
        webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token,
      )

      stub_request(:get, "/mapit/")

      link_status_requester.call

      expect(stub_1).to have_been_requested
      expect(stub_2).to have_been_requested
      expect(stub_3).to have_been_requested
    end
  end

  context "with homepage URLs and links for disabled Services" do
    let!(:disabled_service_link) { create(:link_for_disabled_service) }

    it "does not test links other than the local authority homepage" do
      homepage_stub = link_checker_api_create_batch(
        uris: [disabled_service_link.local_authority.homepage_url],
        webhook_uri: "http://local-links-manager.dev.gov.uk/link-check-callback",
        webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token,
      )

      homepage_and_link_stub = link_checker_api_create_batch(
        uris: [disabled_service_link.url, disabled_service_link.local_authority.homepage_url],
        webhook_uri: "http://local-links-manager.dev.gov.uk/link-check-callback",
        webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token,
      )

      link_status_requester.call

      expect(homepage_stub).to have_been_requested
      expect(homepage_and_link_stub).not_to have_been_requested
    end
  end

  context "links for an authority" do
    let(:local_authority_1) { create(:local_authority, slug: "ambridge", homepage_url: "https://www.ambridge.gov.uk") }
    let!(:link_1) { create(:link, local_authority: local_authority_1, url: 'http://www.example.com/example1.html') }
    let!(:missing_link) { create(:missing_link, local_authority: local_authority_1) }

    it "makes a batch request to the link checker API not including missing links" do
      stub_1 = link_checker_api_create_batch(
        uris: [link_1.url, local_authority_1.homepage_url],
        webhook_uri: "http://local-links-manager.dev.gov.uk/link-check-callback",
        webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token,
      )

      stub_request(:get, "/mapit/")

      link_status_requester.check_authority_urls "ambridge"

      expect(stub_1).to have_been_requested
    end
  end
end
