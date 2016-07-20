require 'rails_helper'
require 'local-links-manager/check_links/link_checker'

describe LocalLinksManager::CheckLinks::LinkChecker do
  let(:link_1) { 'http://www.lewisham.gov.uk/education/Educating-your-child-at-home.aspx' }

  before do
    @time = Timecop.freeze('2016-06-21 09:26:56 +0100')
  end

  subject(:link_checker) { LocalLinksManager::CheckLinks::LinkChecker.new }

  describe '#check_link' do
    it 'retrieves the status code for a link and the time it was checked' do
      stub_request(:get, link_1).to_return(status: 200)

      expect(link_checker.check_link(link_1)).to eq(status: '200', checked_at: @time)
    end

    it 'follows redirected links' do
      stub_request(:get, 'http://www.lewisham.gov.uk').to_return(status: 200)
      stub_request(:get, link_1).to_return(status: 301, headers: { 'location' => 'http://www.lewisham.gov.uk' })

      expect(link_checker.check_link(link_1)).to eq(status: '200', checked_at: @time)
    end

    context 'error handling' do
      let(:link) { "http://some-link.com" }
      let(:connection) { double :connection }

      it 'returns error message when connection fails' do
        stub_request(:get, "http://some-link.com/").and_raise(Faraday::ConnectionFailed, "connection failed")

        expect(link_checker.check_link(link)).to eq(status: "Connection failed", checked_at: @time)
      end

      it 'returns error message when request times out' do
        stub_request(:get, "http://some-link.com/").to_timeout

        expect(link_checker.check_link(link)).to eq(status: "Timeout Error", checked_at: @time)
      end

      it 'returns error message when SLL error occurs' do
        stub_request(:get, "http://some-link.com/").and_raise(Faraday::SSLError, "ssl error")

        expect(link_checker.check_link(link)).to eq(status: "SSL Error", checked_at: @time)
      end

      it 'returns error message when redirect limit is reached' do
        stub_request(:get, "http://some-link.com/").and_raise(FaradayMiddleware::RedirectLimitReached, "redirect limit reached")

        expect(link_checker.check_link(link)).to eq(status: "Too many redirects", checked_at: @time)
      end

      it 'returns error message when URI is invalid' do
        stub_request(:get, "http://some-link.com/").and_raise(URI::InvalidURIError, "invalid URI")

        expect(link_checker.check_link(link)).to eq(status: "Invalid URI", checked_at: @time)
      end

      it 'returns error message for any unexpected error' do
        stub_request(:get, "http://some-link.com/").and_raise(StandardError, "some unknown error")

        expect(link_checker.check_link(link)).to eq(status: "StandardError", checked_at: @time)
      end
    end
  end
end
