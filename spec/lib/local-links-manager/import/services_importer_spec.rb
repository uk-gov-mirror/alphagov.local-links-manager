require 'rails_helper'
require 'local-links-manager/import/services_importer'

describe LocalLinksManager::Import::ServicesImporter do
  describe '#import_records' do
    let(:csv_downloader) { instance_double CsvDownloader }

    context 'when services download is successful' do
      it 'imports services' do
        csv_rows = [
          {
            lgsl_code: "1614",
            label: "16 to 19 bursary fund",
          },
          {
            lgsl_code: "13",
            label: "Abandoned shopping trolleys",
          }
        ]

        allow(csv_downloader).to receive(:download).and_return(csv_rows)

        LocalLinksManager::Import::ServicesImporter.new(csv_downloader).import_records

        expect(Service.count).to eq(2)

        service = Service.find_by(lgsl_code: 1614)
        expect(service.label).to eq("16 to 19 bursary fund")
        expect(service.slug).to eq("16-to-19-bursary-fund")
      end
    end

    context 'when services download is not successful' do
      it 'logs the error on failed download' do
        allow(csv_downloader).to receive(:download)
          .and_raise(CsvDownloader::DownloadError, "Error downloading CSV")

        expect(Rails.logger).to receive(:error).with("Error downloading CSV")

        LocalLinksManager::Import::ServicesImporter.new(csv_downloader).import_records
      end
    end

    context 'when CSV data is malformed' do
      it 'logs an error that it failed importing' do
        allow(csv_downloader).to receive(:download)
          .and_raise(CsvDownloader::DownloadError, "Malformed CSV error")

        expect(Rails.logger).to receive(:error).with("Malformed CSV error")

        LocalLinksManager::Import::ServicesImporter.new(csv_downloader).import_records
      end
    end
  end
end
