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

  it { is_expected.to have_many(:service_interactions) }

  describe '.for_tier' do
    let!(:all_service) { FactoryGirl.create(:service, :all_tiers) }
    let!(:district_service) { FactoryGirl.create(:service, :district_unitary) }
    let!(:county_service) { FactoryGirl.create(:service, :county_unitary) }
    let!(:nil_service) { FactoryGirl.create(:service) }

    it 'returns all services with a tier when asked for "unitary"' do
      expect(described_class.for_tier(Tier.unitary)).to match_array([all_service, district_service, county_service])
    end

    it 'returns services with an "all" or "district/unitary" tier when asked for "distrct"' do
      expect(described_class.for_tier(Tier.district)).to match_array([all_service, district_service])
    end

    it 'returns services with an "all" or "county/unitary" tier when asked for "county"' do
      expect(described_class.for_tier(Tier.county)).to match_array([all_service, county_service])
    end
  end

  describe "#update_broken_link_count" do
    it "updates the broken_link_count" do
      link = FactoryGirl.create(:link, status: 500)
      service = link.service
      expect { service.update_broken_link_count }
        .to change { service.broken_link_count }
        .from(0).to(1)
    end

    it "ignores unchecked links" do
      service = FactoryGirl.create(:service, broken_link_count: 1)
      FactoryGirl.create(:link, service: service, status: nil)
      expect { service.update_broken_link_count }
        .to change { service.broken_link_count }
        .from(1).to(0)
    end
  end
end
