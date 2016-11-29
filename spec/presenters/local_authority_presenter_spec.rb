require 'support/url_status_presentation'

describe LocalAuthorityPresenter do
  it_behaves_like "a UrlStatusPresentation module"

  describe '#homepage_status' do
    let(:local_authority) { double(:local_authority) }
    let(:presenter) { described_class.new(local_authority) }

    it 'returns the homepage URL\'s status description if a URL is present' do
      allow(local_authority).to receive(:homepage_url).and_return('http://example.com')
      allow(local_authority).to receive(:status).and_return('200')
      expect(presenter.homepage_status).to eq('Good')
    end

    it 'returns "No link" if the homepage URL is set to nil' do
      allow(local_authority).to receive(:homepage_url).and_return(nil)
      expect(presenter.homepage_status).to eq('No link')
    end

    it 'returns "No link" if the homepage URL is set to an empty string' do
      allow(local_authority).to receive(:homepage_url).and_return('')
      expect(presenter.homepage_status).to eq('No link')
    end
  end

  describe '#homepage_link_last_checked' do
    let(:local_authority) { double(:local_authority) }
    let(:presenter) { described_class.new(local_authority) }

    it 'returns the time the URL was last checked if a URL is present' do
      time = Timecop.freeze(Time.now)
      allow(local_authority).to receive(:homepage_url).and_return('http://example.com')
      allow(local_authority).to receive(:link_last_checked).and_return(time - (60 * 60))

      expect(presenter.homepage_link_last_checked).to eq('Checked about 1 hour ago')
    end

    it 'returns an empty string if the homepage URL is set to nil' do
      allow(local_authority).to receive(:homepage_url).and_return(nil)
      expect(presenter.homepage_link_last_checked).to be_empty
    end

    it 'returns an empty string if the homepage URL is set to an empty string' do
      allow(local_authority).to receive(:homepage_url).and_return('')
      expect(presenter.homepage_link_last_checked).to be_empty
    end
  end
end
