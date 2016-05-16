require 'rails_helper'

RSpec.describe Service, type: :model do
  before(:each) do
    FactoryGirl.create(:service)
  end

  it { is_expected.to validate_presence_of(:lgsl_code) }
  it { is_expected.to validate_presence_of(:label) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_uniqueness_of(:lgsl_code) }
  it { is_expected.to validate_uniqueness_of(:label) }
  it { is_expected.to validate_uniqueness_of(:slug) }
  it { is_expected.to validate_inclusion_of(:tier).in_array(%w{all county/unitary district/unitary}) }
  it { is_expected.to allow_value(nil).for(:tier) }

  it { is_expected.to have_many(:service_interactions) }

  describe '.for_tier' do
    let!(:all_service) { FactoryGirl.create(:service, lgsl_code: 1, slug: 'all-service', label: 'all service', tier: 'all') }
    let!(:district_service) { FactoryGirl.create(:service, lgsl_code: 2, slug: 'district-service', label: 'district service', tier: 'district/unitary') }
    let!(:county_service) { FactoryGirl.create(:service, lgsl_code: 3, slug: 'county-service', label: 'county service', tier: 'county/unitary') }
    let!(:nil_service) { FactoryGirl.create(:service, lgsl_code: 4, slug: 'nil-service', label: 'nil service', tier: nil) }

    it 'returns all services with a tier when asked for "all"' do
      expect(described_class.for_tier('all')).to match_array([all_service, district_service, county_service])
    end

    it 'returns all services with a tier when asked for "unitary"' do
      expect(described_class.for_tier('unitary')).to match_array([all_service, district_service, county_service])
    end

    it 'returns services with an "all" or "district/unitary" tier when asked for "distrct"' do
      expect(described_class.for_tier('district')).to match_array([all_service, district_service])
    end

    it 'returns services with an "all" or "county/unitary" tier when asked for "county"' do
      expect(described_class.for_tier('county')).to match_array([all_service, county_service])
    end

    it 'raises an ArgumentError for any other requested tier' do
      expect {
        described_class.for_tier('hats')
      }.to raise_error(ArgumentError, "invalid tier 'hats'")
    end
  end

  describe '#provided_by?' do
    let(:district) { FactoryGirl.build(:local_authority, tier: 'district') }
    let(:county) { FactoryGirl.build(:local_authority, tier: 'county') }
    let(:unitary) { FactoryGirl.build(:local_authority, tier: 'unitary') }

    context 'when the tier is blank' do
      subject { FactoryGirl.build(:service, tier: nil) }
      it 'is false for a district council' do
        expect(subject).not_to be_provided_by(district)
      end
      it 'is false for a county council' do
        expect(subject).not_to be_provided_by(county)
      end
      it 'is false for a unitary council' do
        expect(subject).not_to be_provided_by(unitary)
      end
    end

    context 'when the tier is all' do
      subject { FactoryGirl.build(:service, tier: 'all') }
      it 'is true for a district council' do
        expect(subject).to be_provided_by(district)
      end
      it 'is true for a county council' do
        expect(subject).to be_provided_by(county)
      end
      it 'is true for a unitary council' do
        expect(subject).to be_provided_by(unitary)
      end
    end

    context 'when the tier is district/unitary' do
      subject { FactoryGirl.build(:service, tier: 'district/unitary') }
      it 'is true for a district council' do
        expect(subject).to be_provided_by(district)
      end
      it 'is false for a county council' do
        expect(subject).not_to be_provided_by(county)
      end
      it 'is true for a unitary council' do
        expect(subject).to be_provided_by(unitary)
      end
    end

    context 'when the tier is county/unitary' do
      subject { FactoryGirl.build(:service, tier: 'county/unitary') }
      it 'is false for a district council' do
        expect(subject).not_to be_provided_by(district)
      end
      it 'is true for a county council' do
        expect(subject).to be_provided_by(county)
      end
      it 'is true for a unitary council' do
        expect(subject).to be_provided_by(unitary)
      end
    end
  end
end
