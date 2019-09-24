RSpec.describe Service, type: :model do
  before(:each) do
    create(:service)
  end

  it { is_expected.to validate_presence_of(:lgsl_code) }
  it { is_expected.to validate_presence_of(:label) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_uniqueness_of(:lgsl_code) }
  it { is_expected.to validate_uniqueness_of(:label) }
  it { is_expected.to validate_uniqueness_of(:slug) }

  it { is_expected.to have_many(:service_interactions) }

  describe "#tiers" do
    subject { create(:service, :all_tiers) }
    let(:result) { subject.tiers }

    it "returns an array of tier names" do
      expect(result).to match_array(%w[unitary district county])
    end
  end

  describe "#update_broken_link_count" do
    it "updates the broken_link_count" do
      link = create(:link, status: "broken")
      service = link.service
      expect { service.update_broken_link_count }
        .to change { service.broken_link_count }
        .from(0).to(1)
    end

    it "ignores unchecked links" do
      service = create(:service, broken_link_count: 1)
      create(:link, service: service, status: nil)
      expect { service.update_broken_link_count }
        .to change { service.broken_link_count }
        .from(1).to(0)
    end
  end

  describe "#delete_all_tiers" do
    it "deletes all tiers associated with a service" do
      service = create(:service, :all_tiers)
      service.delete_all_tiers
      expect(service.tiers).to be_empty
    end
  end

  describe "#required_tiers" do
    it "returns the correct tiers" do
      service = create(:service)
      expect(service.required_tiers("all")).to eq([2, 3, 1])
    end
  end
end
