require 'support/url_status_presentation'

describe LocalAuthorityPresenter do
  it_behaves_like "a UrlStatusPresentation module"

  describe '#homepage_button_text' do
    let(:local_authority) { double(:local_authority) }
    let(:presenter) { described_class.new(local_authority) }

    it 'returns "Edit link" if a homepage URL is present' do
      allow(local_authority).to receive(:homepage_url).and_return('http://example.com')
      expect(presenter.homepage_button_text).to eq('Edit link')
    end

    it 'returns "Add link" if a homepage URL is not present' do
      allow(local_authority).to receive(:homepage_url).and_return(nil)
      expect(presenter.homepage_button_text).to eq('Add link')
    end
  end
end
