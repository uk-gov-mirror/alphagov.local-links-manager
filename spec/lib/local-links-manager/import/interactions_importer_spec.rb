require 'rails_helper'
require 'local-links-manager/import/interactions_importer'

describe LocalLinksManager::Import::InteractionsImporter, :csv_importer do
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

        stub_csv_rows(csv_rows)

        LocalLinksManager::Import::InteractionsImporter.new(csv_downloader).import_records

        expect(Interaction.count).to eq(2)

        interaction = Interaction.find_by(lgil_code: 30)
        expect(interaction.label).to eq("Application for exemption")
        expect(interaction.slug).to eq("application-for-exemption")
      end
    end

    context 'when interactions download is not successful' do
      it 'logs the error on failed download' do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(CsvDownloader::DownloadError, "Error downloading CSV")

        expect(Rails.logger).to receive(:error).with("Error downloading CSV")

        LocalLinksManager::Import::InteractionsImporter.new(csv_downloader).import_records
      end
    end

    context 'when CSV data is malformed' do
      it 'logs an error that it failed importing' do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(CsvDownloader::DownloadError, "Malformed CSV error")

        expect(Rails.logger).to receive(:error).with("Malformed CSV error")

        LocalLinksManager::Import::InteractionsImporter.new(csv_downloader).import_records
      end
    end

    context 'check imported data' do
      let(:import_comparer) { ImportComparer.new("interaction") }
      let(:importer) { LocalLinksManager::Import::InteractionsImporter.new(csv_downloader, import_comparer) }

      context 'when an interaction is no longer in the CSV' do
        it 'alerts Icinga that an interaction is now missing and does not delete anything' do
          FactoryGirl.create(:interaction, lgil_code: "0", label: "Applications for service")
          FactoryGirl.create(:interaction, lgil_code: "30", label: "Applications for exemption")

          csv_rows = [
            {
              lgil_code: "0",
              label: "Applications for service",
            }
          ]
          stub_csv_rows(csv_rows)

          expect(import_comparer).to receive(:alert_missing_records)

          importer.import_records

          expect(Interaction.count).to eq(2)
        end
      end

      context 'when no interactions are missing from the CSV' do
        it 'tells Icinga that everything is fine' do
          FactoryGirl.create(:interaction, lgil_code: "0", label: "Applications for service")

          csv_rows = [
            {
              lgil_code: "0",
              label: "Applications for service",
            }
          ]
          stub_csv_rows(csv_rows)

          expect(import_comparer).to receive(:confirm_records_are_present)

          importer.import_records
        end
      end
    end
  end
end
