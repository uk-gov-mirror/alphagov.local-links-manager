require 'rails_helper'
require 'local-links-manager/import/interactions_importer'

describe LocalLinksManager::Import::InteractionsImporter do
  describe '#import_records' do
    let(:csv_downloader) { instance_double CsvDownloader }

    context 'when interactions download is successful' do
      it 'imports interactions' do
        csv_rows = [
          {
            lgil_code: "0",
            label: "Applications for service",
          },
          {
            lgil_code: "30",
            label: "Application for exemption",
          }
        ]

        allow(csv_downloader).to receive(:download).and_return(csv_rows)

        LocalLinksManager::Import::InteractionsImporter.new(csv_downloader).import_records

        expect(Interaction.count).to eq(2)

        interaction = Interaction.find_by(lgil_code: 30)
        expect(interaction.label).to eq("Application for exemption")
      end
    end

    context 'when interactions download is not successful' do
      it 'logs the error on failed download' do
        allow(csv_downloader).to receive(:download)
          .and_raise(CsvDownloader::DownloadError, "Error downloading CSV")

        expect(Rails.logger).to receive(:error).with("Error downloading CSV")

        LocalLinksManager::Import::InteractionsImporter.new(csv_downloader).import_records
      end
    end

    context 'when CSV data is malformed' do
      it 'logs an error that it failed importing' do
        allow(csv_downloader).to receive(:download)
          .and_raise(CsvDownloader::DownloadError, "Malformed CSV error")

        expect(Rails.logger).to receive(:error).with("Malformed CSV error")

        LocalLinksManager::Import::InteractionsImporter.new(csv_downloader).import_records
      end
    end
  end
end
