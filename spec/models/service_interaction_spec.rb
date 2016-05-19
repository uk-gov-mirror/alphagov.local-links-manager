require 'rails_helper'

RSpec.describe ServiceInteraction, type: :model do
  describe 'validations' do
    before(:each) do
      FactoryGirl.create(:service_interaction)
    end
    it { is_expected.to validate_presence_of(:service_id) }
    it { is_expected.to validate_presence_of(:interaction_id) }

    it { is_expected.to validate_uniqueness_of(:service_id).scoped_to(:interaction_id) }

    it { is_expected.to belong_to(:service) }
    it { is_expected.to belong_to(:interaction) }
  end

  describe '.find_by_lgsl_and_lgil' do
    it 'returns the service interaction with a service matching the supplied lgsl_code and interaction matching the supplied lgil_code' do
      service_100 = FactoryGirl.create(:service, lgsl_code: 100, label: 'Service 100')
      interaction_1 = FactoryGirl.create(:interaction, lgil_code: 1, label: 'Interaction 1')
      service_interaction_100_1 = FactoryGirl.create(:service_interaction, service: service_100, interaction: interaction_1)

      expect(described_class.find_by_lgsl_and_lgil(100, 1)).to eq(service_interaction_100_1)
    end

    it 'returns nil if no service interaction exists for the supplied lgsl and lgil codes' do
      service_100 = FactoryGirl.create(:service, lgsl_code: 100, label: 'Service 100')
      FactoryGirl.create(:service, lgsl_code: 200, label: 'Service 200')
      interaction_1 = FactoryGirl.create(:interaction, lgil_code: 1, label: 'Interaction 1')
      FactoryGirl.create(:interaction, lgil_code: 2, label: 'Interaction 2')
      FactoryGirl.create(:service_interaction, service: service_100, interaction: interaction_1)

      # service interactions exist for service, but not interaction
      expect(described_class.find_by_lgsl_and_lgil(100, 2)).to be_nil
      # service interactions exist for interaction, but not service
      expect(described_class.find_by_lgsl_and_lgil(200, 1)).to be_nil
    end

    it 'returns nil if the supplied lgsl is not a valid service' do
      FactoryGirl.create(:interaction, lgil_code: 1, label: 'Interaction 1')

      expect(described_class.find_by_lgsl_and_lgil(100, 1)).to be_nil
    end

    it 'returns nil if the supplied lgil is not a valid interaction' do
      FactoryGirl.create(:service, lgsl_code: 100, label: 'Service 100')

      expect(described_class.find_by_lgsl_and_lgil(100, 1)).to be_nil
    end

    context 'to avoid n+1 queries' do
      let(:service) { FactoryGirl.create(:service, lgsl_code: 100, label: 'Service 100') }
      let(:interaction) { FactoryGirl.create(:interaction, lgil_code: 1, label: 'Interaction 1') }
      before do
        FactoryGirl.create(:service_interaction, service: service, interaction: interaction)
      end

      subject(:found_record) { ServiceInteraction.find_by_lgsl_and_lgil(100, 1) }

      it 'preloads the service on the fetched record' do
        expect(found_record.association(:service)).to be_loaded
      end

      it 'preloads the interaction on the fetched record' do
        expect(found_record.association(:interaction)).to be_loaded
      end
    end
  end
end
