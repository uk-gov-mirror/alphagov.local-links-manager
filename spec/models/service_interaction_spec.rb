RSpec.describe ServiceInteraction, type: :model do
  describe 'validations' do
    before(:each) do
      create(:service_interaction)
    end
    it { is_expected.to validate_presence_of(:service_id) }
    it { is_expected.to validate_presence_of(:interaction_id) }

    it { is_expected.to validate_uniqueness_of(:service_id).scoped_to(:interaction_id) }

    it { is_expected.to belong_to(:service) }
    it { is_expected.to belong_to(:interaction) }
  end

  describe '.find_by_lgsl_and_lgil' do
    it 'returns the service interaction with a service matching the supplied lgsl_code and interaction matching the supplied lgil_code' do
      service100 = create(:service, lgsl_code: 100, label: 'Service 100')
      interaction1 = create(:interaction, lgil_code: 1, label: 'Interaction 1')
      service100_interaction1 = create(:service_interaction, service: service100, interaction: interaction1)

      expect(described_class.find_by_lgsl_and_lgil(100, 1)).to eq(service100_interaction1)
    end

    it 'returns nil if no service interaction exists for the supplied lgsl and lgil codes' do
      service100 = create(:service, lgsl_code: 100, label: 'Service 100')
      create(:service, lgsl_code: 200, label: 'Service 200')
      interaction1 = create(:interaction, lgil_code: 1, label: 'Interaction 1')
      create(:interaction, lgil_code: 2, label: 'Interaction 2')
      create(:service_interaction, service: service100, interaction: interaction1)

      # service interactions exist for service, but not interaction
      expect(described_class.find_by_lgsl_and_lgil(100, 2)).to be_nil
      # service interactions exist for interaction, but not service
      expect(described_class.find_by_lgsl_and_lgil(200, 1)).to be_nil
    end

    it 'returns nil if the supplied lgsl is not a valid service' do
      create(:interaction, lgil_code: 1, label: 'Interaction 1')

      expect(described_class.find_by_lgsl_and_lgil(100, 1)).to be_nil
    end

    it 'returns nil if the supplied lgil is not a valid interaction' do
      create(:service, lgsl_code: 100, label: 'Service 100')

      expect(described_class.find_by_lgsl_and_lgil(100, 1)).to be_nil
    end

    context 'to avoid n+1 queries' do
      let(:service) { create(:service, lgsl_code: 100, label: 'Service 100') }
      let(:interaction) { create(:interaction, lgil_code: 1, label: 'Interaction 1') }
      before do
        create(:service_interaction, service: service, interaction: interaction)
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
