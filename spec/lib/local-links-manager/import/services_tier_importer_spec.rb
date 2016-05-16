require 'rails_helper'
require 'local-links-manager/import/services_tier_importer'

describe LocalLinksManager::Import::ServicesTierImporter do
  let(:csv_downloader) { instance_double CsvDownloader }
  subject { described_class.new(csv_downloader) }
  describe 'import_tiers' do
    it 'imports the tiers from the csv file and updates existing services' do
      abandoned_shopping_trolleys = FactoryGirl.create(:service,
        lgsl_code: 1152,
        label: "Abandoned shopping trolleys",
        tier: nil
      )
      arson_reduction = FactoryGirl.create(:service,
        lgsl_code: 800,
        label: "Arson reduction",
        tier: nil
      )
      yellow_lines = FactoryGirl.create(:service,
        lgsl_code: 538,
        label: "Yellow lines",
        tier: nil
      )

      csv_rows = [
        {
          :lgsl_code => '1152',
          'Description' => 'Abandoned shopping trolleys',
          :tier => 'county/unitary'
        },
        {
          :lgsl_code => '800',
          'Description' => 'Arson reduction',
          :tier => 'district/unitary'
        },
        {
          :lgsl_code => '538',
          'Description' => 'Yellow lines',
          :tier => 'all'
        },
      ]
      allow(csv_downloader).to receive(:download).and_return(csv_rows)

      subject.import_tiers

      expect(abandoned_shopping_trolleys.reload.tier).to eq('county/unitary')
      expect(arson_reduction.reload.tier).to eq('district/unitary')
      expect(yellow_lines.reload.tier).to eq('all')
    end

    it 'does not create new services for rows in the csv without a matching Service instance' do
      csv_rows = [
        {
          :lgsl_code => '1152',
          'Description' => 'Abandoned shopping trolleys',
          :tier => 'county/unitary'
        },
      ]
      allow(csv_downloader).to receive(:download).and_return(csv_rows)

      subject.import_tiers

      expect(Service.exists?(lgsl_code: 1152)).to be_falsey
    end

    it 'does not update tiers to be blank' do
      abandoned_shopping_trolleys = FactoryGirl.create(:service,
        lgsl_code: 1152,
        label: "Abandoned shopping trolleys",
        tier: 'all'
      )

      csv_rows = [
        {
          :lgsl_code => '1152',
          'Description' => 'Abandoned shopping trolleys',
          :tier => ''
        },
      ]
      allow(csv_downloader).to receive(:download).and_return(csv_rows)

      subject.import_tiers

      expect(abandoned_shopping_trolleys.reload.tier).not_to be_blank
    end

    it 'does not halt in the face of an error on a single row' do
      abandoned_shopping_trolleys = FactoryGirl.create(:service,
        lgsl_code: 1152,
        label: "Abandoned shopping trolleys",
        tier: nil
      )
      arson_reduction = FactoryGirl.create(:service,
        lgsl_code: 800,
        label: "Arson reduction",
        tier: nil
      )
      soil_excavation = FactoryGirl.create(:service,
        lgsl_code: 1419,
        label: "Soil excavation",
        tier: nil
      )

      csv_rows = [
        {
          :lgsl_code => '1152',
          'Description' => 'Abandoned shopping trolleys',
          :tier => 'county/unitary'
        },
        {
          'Description' => 'No LGSL row',
          :tier => 'all'
        },
        {
          :lgsl_code => '800',
          'Description' => 'Bad tier value row',
          :tier => 'england'
        },
        {
          :lgsl_code => '538',
          'Description' => 'Missing service row',
          :tier => 'district/unitary'
        },
        {
          :lgsl_code => '1419',
          'Description' => 'Soil excavation',
          :tier => 'district/unitary'
        },
      ]
      allow(csv_downloader).to receive(:download).and_return(csv_rows)

      subject.import_tiers

      expect(abandoned_shopping_trolleys.reload.tier).to eq('county/unitary')
      expect(arson_reduction.reload.tier).to be_blank
      expect(soil_excavation.reload.tier).to eq('district/unitary')
    end
  end
end
