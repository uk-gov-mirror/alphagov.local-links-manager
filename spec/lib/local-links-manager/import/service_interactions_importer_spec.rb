require 'rails_helper'
require 'local-links-manager/import/service_interactions_importer'

describe LocalLinksManager::Import::ServiceInteractionsImporter do
  describe '#import_records' do
    let(:csv_downloader) { instance_double CsvDownloader }

    context 'when service interactions download is successful' do
      let!(:service_0) { FactoryGirl.create(:service, lgsl_code: 1614, label: "Bursary Fund Service", slug: "bursary-fund-service") }
      let!(:service_1) { FactoryGirl.create(:service, lgsl_code: 13, label: "Abandoned shopping trolleys", slug: "abandoned-shopping-trolleys") }

      let!(:interaction_0) { FactoryGirl.create(:interaction, lgil_code: 0, label: "Find out about") }
      let!(:interaction_1) { FactoryGirl.create(:interaction, lgil_code: 30, label: "Contact") }

      let(:csv_rows) {
        [
          { lgsl_code: "1614", lgil_code: "0" },
          { lgsl_code: "13", lgil_code: "30" },
          { lgsl_code: "13", lgil_code: "0" },
          { lgsl_code: "1614", lgil_code: "30" },
        ]
      }

      let(:csv_rows_with_missing_entries) {
        [
          { lgsl_code: "1614", lgil_code: nil },
          { lgsl_code: nil, lgil_code: "0" },
        ]
      }

      let(:csv_rows_with_missing_associated_entries) {
        [
          { lgsl_code: "13", lgil_code: "999" },
          { lgsl_code: "999", lgil_code: "30" },
        ]
      }

      it 'imports service interactions' do
        allow(csv_downloader).to receive(:download).and_return(csv_rows)

        LocalLinksManager::Import::ServiceInteractionsImporter.new(csv_downloader).import_records

        expect(ServiceInteraction.count).to eq(4)

        service_interaction = ServiceInteraction.last
        expect(service_interaction.service_id).to eq(service_0.id)
        expect(service_interaction.interaction_id).to eq(interaction_1.id)
      end

      it 'raises error and logs a warning when Identifier or Mapped Identifier is empty' do
        allow(csv_downloader).to receive(:download).and_return(csv_rows_with_missing_entries)

        expect(Rails.logger).to receive(:error).with(/could not be created due to missing Service identifier/)
        expect(Rails.logger).to receive(:error).with(/could not be created due to missing Interaction identifier/)

        LocalLinksManager::Import::ServiceInteractionsImporter.new(csv_downloader).import_records

        expect(ServiceInteraction.count).to eq(0)
      end

      it 'raises error and logs a warning when an associated Service or Interaction is missing' do
        allow(csv_downloader).to receive(:download).and_return(csv_rows_with_missing_associated_entries)

        expect(Rails.logger).to receive(:error).with(/could not be created due to missing Service/)
        expect(Rails.logger).to receive(:error).with(/could not be created due to missing Interaction/)

        LocalLinksManager::Import::ServiceInteractionsImporter.new(csv_downloader).import_records

        expect(ServiceInteraction.count).to eq(0)
      end
    end

    context 'when service interactions download is not successful' do
      it 'logs the error on failed download' do
        allow(csv_downloader).to receive(:download)
          .and_raise(CsvDownloader::DownloadError, "Error downloading CSV")

        expect(Rails.logger).to receive(:error).with("Error downloading CSV")

        LocalLinksManager::Import::ServiceInteractionsImporter.new(csv_downloader).import_records
      end
    end

    context 'when CSV data is malformed' do
      it 'logs an error that it failed importing' do
        allow(csv_downloader).to receive(:download)
          .and_raise(CsvDownloader::DownloadError, "Malformed CSV error")

        expect(Rails.logger).to receive(:error).with("Malformed CSV error")

        LocalLinksManager::Import::ServiceInteractionsImporter.new(csv_downloader).import_records
      end
    end
  end
end
