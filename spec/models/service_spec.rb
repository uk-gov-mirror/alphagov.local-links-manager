require 'rails_helper'

RSpec.describe Service, type: :model do
  before(:each) do
    FactoryGirl.create(:service)
  end

  it { is_expected.to validate_presence_of(:lgsl_code) }
  it { is_expected.to validate_presence_of(:label) }
  it { is_expected.to validate_uniqueness_of(:lgsl_code) }
  it { is_expected.to validate_uniqueness_of(:label) }
  it { is_expected.to validate_inclusion_of(:tier).in_array(%w{all county/unitary district/unitary}) }
  it { is_expected.to allow_value(nil).for(:tier) }

  it { is_expected.to have_many(:service_interactions) }

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
