require 'rails_helper'
require 'local-links-manager/import/enabled_service_checker'

describe LocalLinksManager::Import::EnabledServiceChecker, :csv_importer do
  describe '#enabled_services' do
    let(:csv_downloader) { instance_double LocalLinksManager::Import::CsvDownloader }
    let!(:service_0) { FactoryGirl.create(:disabled_service, lgsl_code: 1614, label: "Bursary Fund Service") }
    let!(:service_1) { FactoryGirl.create(:disabled_service, lgsl_code: 13, label: "Abandoned shopping trolleys") }
    let!(:service_2) { FactoryGirl.create(:disabled_service, lgsl_code: 10, label: "Special educational needs - placement in mainstream school") }
    let!(:service_3) { FactoryGirl.create(:service, lgsl_code: 47) }

    context 'when the csv is downloaded successfully' do
      let(:csv_rows) { [{ "LGSL" => "1614" }, { "LGSL" => "13" }] }

      before do
        stub_csv_rows(csv_rows)
      end

      it 'returns success' do
        expect(LocalLinksManager::Import::EnabledServiceChecker.new(csv_downloader).enable_services).to be_successful
      end

      it 'sets enabled to true for required services' do
        LocalLinksManager::Import::EnabledServiceChecker.new(csv_downloader).enable_services
        expect(service_0.reload.enabled).to eq(true)
        expect(service_1.reload.enabled).to eq(true)
      end

      it 'should not enable an unrequired service' do
        LocalLinksManager::Import::EnabledServiceChecker.new(csv_downloader).enable_services
        expect(service_2.reload.enabled).to eq(false)
      end

      it 'should disable a previously required service that is no longer required' do
        LocalLinksManager::Import::EnabledServiceChecker.new(csv_downloader).enable_services
        expect(service_3.reload.enabled).to eq(false)
      end
    end

    context 'when the csv download is not successful' do
      it 'logs the error on failed download' do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(LocalLinksManager::Import::CsvDownloader::DownloadError, "Error downloading CSV")

        expect(Rails.logger).to receive(:error).with("Error downloading CSV")

        response = LocalLinksManager::Import::EnabledServiceChecker.new(csv_downloader).enable_services
        expect(response).to_not be_successful
        expect(response.errors).to include('Error downloading CSV')
      end
    end

    context 'when CSV data is malformed' do
      it 'logs an error that it failed importing' do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(LocalLinksManager::Import::CsvDownloader::DownloadError, "Malformed CSV error")

        expect(Rails.logger).to receive(:error).with("Malformed CSV error")

        response = LocalLinksManager::Import::EnabledServiceChecker.new(csv_downloader).enable_services
        expect(response).to_not be_successful
        expect(response.errors).to include('Malformed CSV error')
      end
    end

    context 'when runtime error is raised' do
      it 'logs an error that it failed importing' do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(RuntimeError, "RuntimeError")

        expect(Rails.logger).to receive(:error).with(/Error RuntimeError/)

        response = LocalLinksManager::Import::EnabledServiceChecker.new(csv_downloader).enable_services
        expect(response).to_not be_successful
        expect(response.errors).to include(/Error RuntimeError/)
      end
    end

    context 'check imported data' do
      let(:csv_rows) { [{ "LGSL" => "1614" }, { "LGSL" => "13" }, { "LGSL" => "100010001" }] }

      before do
        stub_csv_rows(csv_rows)
      end

      it 'should warn when an lgsl code is in the csv that does not correspond to a service' do
        checker = LocalLinksManager::Import::EnabledServiceChecker.new(csv_downloader)

        response = checker.enable_services
        expect(response).not_to be_successful
        expect(response.errors).to include("1 Service is not present.\n100010001\n")
      end
    end
  end
end
