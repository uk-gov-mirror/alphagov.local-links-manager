require 'rails_helper'
require 'local-links-manager/import/services_importer'

describe LocalLinksManager::Import::ServicesImporter, :csv_importer do
  describe '#import_records' do
    let(:csv_downloader) { instance_double CsvDownloader }
    let(:import_comparer) { ImportComparer.new("service") }

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

        stub_csv_rows(csv_rows)

        LocalLinksManager::Import::ServicesImporter.new(csv_downloader).import_records

        expect(Service.count).to eq(2)

        service = Service.find_by(lgsl_code: 1614)
        expect(service.label).to eq("16 to 19 bursary fund")
        expect(service.slug).to eq("16-to-19-bursary-fund")
      end
    end

    context 'when services download is not successful' do
      it 'logs the error on failed download' do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(CsvDownloader::DownloadError, "Error downloading CSV")

        expect(Rails.logger).to receive(:error).with("Error downloading CSV")

        LocalLinksManager::Import::ServicesImporter.new(csv_downloader).import_records
      end
    end

    context 'when CSV data is malformed' do
      it 'logs an error that it failed importing' do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(CsvDownloader::DownloadError, "Malformed CSV error")

        expect(Rails.logger).to receive(:error).with("Malformed CSV error")

        LocalLinksManager::Import::ServicesImporter.new(csv_downloader).import_records
      end
    end

    context 'check imported data' do
      let(:import_comparer) { ImportComparer.new("local authority") }
      let(:importer) { LocalLinksManager::Import::ServicesImporter.new(csv_downloader, import_comparer) }

      context 'when a service is no longer in the CSV' do
        it 'alerts Icinga that a service is now missing and does not delete anything' do
          FactoryGirl.create(:service, lgsl_code: "1614", label: "16 to 19 bursary fund")
          FactoryGirl.create(:service, lgsl_code: "13", label: "Abandoned shopping trolleys")
          FactoryGirl.create(:service, lgsl_code: "427", label: "Overheated porridge")

          csv_rows = [
            {
              lgsl_code: "1614",
              label: "16 to 19 bursary fund",
            }
          ]
          stub_csv_rows(csv_rows)

          expect(import_comparer).to receive(:alert_missing_records)

          importer.import_records

          expect(Service.count).to eq(3)
        end
      end

      context 'when no services are missing from the CSV' do
        it 'tells Icinga that everything is fine' do
          FactoryGirl.create(:service, lgsl_code: "1614", label: "16 to 19 bursary fund")

          csv_rows = [
            {
              lgsl_code: "1614",
              label: "16 to 19 bursary fund",
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
