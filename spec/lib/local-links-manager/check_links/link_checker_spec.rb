require 'rails_helper'
require 'local-links-manager/check_links/link_checker'

describe LocalLinksManager::CheckLinks::LinkChecker do
  let(:link_1) { 'http://www.lewisham.gov.uk/education/Educating-your-child-at-home.aspx' }
  let(:link_2) { 'http://www.lewisham.gov.uk/education/student-pupil-support/default.aspx' }
  let(:links)  { [link_1, link_2] }

  before do
    @time = Timecop.freeze('2016-06-21 09:26:56 +0100')
  end

  subject(:link_checker) { LocalLinksManager::CheckLinks::LinkChecker.new }

  after(:each) do
    Timecop.return
  end

  describe '#check_links' do
    it 'retrieves the status code for a link and the time it was checked' do
      stub_request(:get, link_1).to_return(status: 200)
      stub_request(:get, link_2).to_return(status: 200)

      expect(link_checker.check_links(links)).to eq(
        link_1 => ['200', @time],
        link_2 => ['200', @time])
    end

    it 'follows redirected links' do
      stub_request(:get, 'http://www.lewisham.gov.uk').to_return(status: 200)
      stub_request(:get, link_1).to_return(status: 301, headers: { 'location' => 'http://www.lewisham.gov.uk' })
      stub_request(:get, link_2).to_return(status: 200)

      link_checker.check_links(links)

      expect(link_checker.link_responses).to eq(
        link_1 => ['200', @time],
        link_2 => ['200', @time])
    end

    context 'error handling' do
      let(:link) { "http://some-link.com" }
      let(:connection) { double :connection }

      it 'returns error message when connection fails' do
        stub_request(:get, "http://some-link.com/").and_raise(Faraday::ConnectionFailed, "connection failed")

        expect(subject.check_links([link])).to eq(link => ["Connection failed", @time])
      end

      it 'returns error message when request times out' do
        stub_request(:get, "http://some-link.com/").to_timeout

        expect(subject.check_links([link])).to eq(link => ["Timeout Error", @time])
      end

      it 'returns error message when SLL error occurs' do
        stub_request(:get, "http://some-link.com/").and_raise(Faraday::SSLError, "ssl error")

        expect(subject.check_links([link])).to eq(link => ["SSL Error", @time])
      end

      it 'returns error message when redirect limit is reached' do
        stub_request(:get, "http://some-link.com/").and_raise(FaradayMiddleware::RedirectLimitReached, "redirect limit reached")

        expect(subject.check_links([link])).to eq(link => ["Too many redirects", @time])
      end

      it 'returns error message when URI is invalid' do
        stub_request(:get, "http://some-link.com/").and_raise(URI::InvalidURIError, "invalid URI")

        expect(subject.check_links([link])).to eq(link => ["Invalid URI", @time])
      end

      it 'returns error message for any unexpected error' do
        stub_request(:get, "http://some-link.com/").and_raise(StandardError, "some unknown error")

        expect(subject.check_links([link])).to eq(link => ["StandardError", @time])
      end
    end
  end
end
