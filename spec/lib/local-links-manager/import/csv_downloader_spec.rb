require 'rails_helper'
require 'local-links-manager/import/csv_downloader'

describe CsvDownloader do
  let(:csv_data) { File.read(fixture_file('sample.csv')) }
  let(:malformed_csv_data) { File.read(fixture_file('sample_malformed.csv')) }

  let(:url) { "http://standards.esd.org.uk/csv?uri=list/englishAndWelshServices" }
  subject(:CsvDownloader) { described_class.new(url) }

  def fixture_file(file)
    File.expand_path("fixtures/" + file, File.dirname(__FILE__))
  end

  def stub_csv_download(data)
    stub_request(:any, url)
      .to_return(
        body: data,
        status: 200,
        headers: { 'Content-Length' => data.length }
    )
  end

  def stub_failed_csv_download
    stub_request(:any, url)
      .to_return(body: nil, status: 404)
  end

  describe '#download' do
    context 'when download is successful' do
      it 'returns the parsed rows' do
        stub_csv_download(csv_data)

        expected_rows = [
          {
            "Identifier" => "1614",
            "Label" => "16 to 19 bursary fund",
            "Description" => "They might struggle with the costs",
          },
          {
            "Identifier" => "13",
            "Label" => "Abandoned shopping trolleys",
            "Description" => "Abandoned shopping trolleys have a negative impact",
          }
        ]

        expect(subject.download.map { |r| r.to_h.compact }).to eq(expected_rows)
      end
    end

    context 'when download is not successful' do
      it 'raises the error for failed download' do
        stub_failed_csv_download

        expect { subject.download }.to raise_error(CsvDownloader::DownloadError)
      end
    end

    context 'when CSV data is malformed' do
      it 'raises the error for malformed CSV' do
        stub_csv_download(malformed_csv_data)

        expect { subject.download }.to raise_error(CsvDownloader::MalformedCSVError)
      end
    end
  end
end
