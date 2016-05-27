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
      it 'yields the csv parser' do
        stub_csv_download(csv_data)

        expect { |b| subject.download(&b) }.to yield_with_args(instance_of(CSV::Table))
      end

      it 'contains the parsed rows' do
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

        subject.download do |csv|
          expect(csv.map { |r| r.to_h.compact }).to eq(expected_rows)
        end
      end

      it 'optionally converts the headers' do
        stub_csv_download(csv_data)

        header_conversions = {
          "Identifier" => :lgsl_code,
          "Label" => :label,
          "Description" => :description,
        }

        downloader = CsvDownloader.new(url, header_conversions: header_conversions)

        expected_rows = [
          {
            lgsl_code: "1614",
            label: "16 to 19 bursary fund",
            description: "They might struggle with the costs",
          },
          {
            lgsl_code: "13",
            label: "Abandoned shopping trolleys",
            description: "Abandoned shopping trolleys have a negative impact",
          }
        ]

        downloader.download do |csv|
          expect(csv.map { |r| r.to_h.compact }).to eq(expected_rows)
        end
      end

      it 'converts data to utf-8 correctly' do
        windows_encoded_data = "Currency,Symbol\nEUR,\x80\n"
        windows_encoded_data.force_encoding('windows-1252')
        stub_csv_download(windows_encoded_data)

        downloader = CsvDownloader.new(url, encoding: 'windows-1252')
        downloader.download do |csv|
          row = csv.first
          expect(row['Currency'].encoding).to eq Encoding::UTF_8
          expect(row['Symbol'].encoding).to eq Encoding::UTF_8
          expect(row['Symbol']).to eq '€'
        end
      end

      it 'optionally converts the data from a specific encoding' do
        iso8859_15_encoded_data = "Currency,Symbol\nEUR,\xA4\n"
        iso8859_15_encoded_data.force_encoding('iso-8859-15')
        stub_csv_download(iso8859_15_encoded_data)

        downloader = CsvDownloader.new(url, encoding: 'iso-8859-15')
        downloader.download do |csv|
          row = csv.first
          expect(row['Currency'].encoding).to eq Encoding::UTF_8
          expect(row['Symbol'].encoding).to eq Encoding::UTF_8
          expect(row['Symbol']).to eq '€'
        end
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

  describe '#each_row' do
    it 'yields each parsed row in turn' do
      stub_csv_download(csv_data)

      expected_rows = [
        CSV::Row.new(
          %w(Identifier Label Description),
          ["1614", "16 to 19 bursary fund", "They might struggle with the costs"]
        ),
        CSV::Row.new(
          %w(Identifier Label Description),
          ["13", "Abandoned shopping trolleys", "Abandoned shopping trolleys have a negative impact"]
        )
      ]

      expect { |b| subject.each_row(&b) }.to yield_successive_args(*expected_rows)
    end
  end
end
