RSpec.shared_examples "a UrlStatusPresentation module" do
  describe '#status_description' do
    let(:presenter) { described_class.new(@link) }

    it 'returns an empty string if status is not present' do
      @link = double(:Link, status: nil)
      expect(presenter.status_description).to eq('')
    end

    it 'returns "Good" if the status is ok' do
      @link = double(:Link, status: 'ok')
      expect(presenter.status_description).to eq('Good')
    end

    it 'returns "Broken:" + error message if the status is broken' do
      @link = double(:Link, status: 'broken', link_errors: { "Client error" => "Received 4xx response" })
      expect(presenter.status_description).to eq('Broken: Client error')
    end

    it 'returns "Note:" + warning message if the status is caution' do
      @link = double(:Link, status: 'caution', link_warnings: { "Multiple redirects" => "Multiple redirects" })
      expect(presenter.status_description).to eq("Note: Multiple redirects")
    end
  end

  describe '#label_status_class' do
    let(:presenter) { described_class.new(@link) }

    it 'returns nil if the status is not present' do
      @link = double(:Link, status: nil)
      expect(presenter.label_status_class).to be_nil
    end

    it 'returns "label label-success" if the status is "200"' do
      @link = double(:Link, status: 'ok')
      expect(presenter.label_status_class).to eq('label label-success')
    end

    it 'returns "label label-info" for a pending status' do
      @link = double(:Link, status: 'pending')
      expect(presenter.label_status_class).to eq('label label-info')
    end

    it 'returns "label label-danger" for a broken status' do
      @link = double(:Link, status: 'broken')
      expect(presenter.label_status_class).to eq('label label-danger')
    end

    it 'returns "label label-warning" for a caution status' do
      @link = double(:Link, status: 'caution')
      expect(presenter.label_status_class).to eq('label label-warning')
    end
  end

  describe '#last_checked' do
    let(:presenter) { described_class.new(@link) }

    it 'returns how long ago the link was last checked if it has been checked' do
      time = Timecop.freeze(Time.now)
      @link = double(:Link, link_last_checked: time - (60 * 60))
      expect(presenter.last_checked).to eq("about 1 hour ago")
    end

    it 'returns "Link not checked if the link has not last checked time' do
      @link = double(:Link, link_last_checked: nil)
      expect(presenter.last_checked).to eq("Link not checked")
    end
  end
end
