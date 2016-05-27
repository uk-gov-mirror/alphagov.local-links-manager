require 'rails_helper'
require 'local-links-manager/import/enabled_service_checker'

describe LocalLinksManager::Import::EnabledServiceChecker, :csv_importer do
  describe '#enabled_services' do
    let(:csv_downloader) { instance_double CsvDownloader }
    let(:csv_rows) { [{ "LGSL" => 1614 }, { "LGSL" => 13 }] }
    let!(:service_0) { FactoryGirl.create(:service, lgsl_code: 1614, label: "Bursary Fund Service") }
    let!(:service_1) { FactoryGirl.create(:service, lgsl_code: 13, label: "Abandoned shopping trolleys") }
    let!(:service_2) { FactoryGirl.create(:service, lgsl_code: 10, label: "Special educational needs - placement in mainstream school") }

    context 'when the csv is downloaded successfully' do
      before do
        stub_csv_rows(csv_rows)
      end

      it 'sets enabled to true for required services' do
        LocalLinksManager::Import::EnabledServiceChecker.new(csv_downloader).enable_services
        expect(service_0.reload.enabled).to eq(true)
        expect(service_1.reload.enabled).to eq(true)
      end

      it 'should not enable an unrequired service' do
        expect(service_2.reload.enabled).to eq(false)
      end
    end
  end
end
