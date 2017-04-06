require 'rails_helper'
require 'local-links-manager/check_links/link_status_requester'

describe LocalLinksManager::CheckLinks::LinkStatusRequester do
  subject(:link_status_requester) { described_class.new }

  context "links for enabled services" do
    let(:local_authority_1) { FactoryGirl.create(:local_authority) }
    let(:local_authority_2) { FactoryGirl.create(:local_authority) }
    let!(:link_1) { FactoryGirl.create(:link, local_authority: local_authority_1, url: 'http://www.example.com') }
    let!(:link_2) { FactoryGirl.create(:link, local_authority: local_authority_2, url: 'http://www.example.com/example.html') }

    it "makes a batch request to the link checker API" do
      stub_1 = stub_request(:post, "http://link-checker-api.dev.gov.uk/batch")
      .with(body: request_body(link_1.url, local_authority_1.homepage_url).to_json)
      .to_return(status: 200)

      stub_2 = stub_request(:post, "http://link-checker-api.dev.gov.uk/batch")
      .with(body: request_body(link_2.url, local_authority_2.homepage_url).to_json)
      .to_return(status: 200)

      stub_request(:get, '/mapit/')

      link_status_requester.call
      expect(stub_1).to have_been_requested
      expect(stub_2).to have_been_requested
    end
  end

  context "with links for disabled Services" do
    let!(:disabled_service_link) { FactoryGirl.create(:link_for_disabled_service) }

    it 'does not test links' do
      stub = stub_request(:post, "http://link-checker-api.dev.gov.uk/batch")
      .with(body: request_body(disabled_service_link.local_authority.homepage_url).to_json)
      .to_return(status: 200)

      link_status_requester.call
      expect(stub).to have_been_requested
    end
  end

  def request_body(*links)
    {
      uris: links,
      callback_uri: "http://local-links-manager.dev.gov.uk/link-check-callback"
    }
  end
end
