RSpec.describe LocalAuthority, type: :model do
  describe "validations" do
    before(:each) do
      create(:local_authority)
    end

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:gss) }
    it { should validate_presence_of(:slug) }
    it { should allow_value(nil).for(:snac) }

    it { should validate_uniqueness_of(:gss) }
    it { should validate_uniqueness_of(:slug) }
    it { should validate_uniqueness_of(:snac) }

    describe "tier_id" do
      [Tier.county, Tier.district, Tier.unitary].each do |tier|
        it { should allow_value(tier).for(:tier_id) }
      end

      it { should_not allow_value(-1).for(:tier_id) }
      it { should_not allow_value(nil).for(:tier_id) }
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:links) }
  end

  describe "#provided_services" do
    let!(:all_service) { create(:service, :all_tiers) }
    let!(:county_service) { create(:service, :county_unitary) }
    let!(:district_service) { create(:service, :district_unitary) }
    let!(:nil_service) { create(:service) }
    let!(:disabled_service) { create(:disabled_service, :district_unitary) }

    context 'for a "district" LA' do
      subject { create(:district_council) }

      it "returns all and district/unitary services that are enabled" do
        expect(subject.provided_services).to match_array([all_service, district_service])
      end
    end

    context 'for a "county" LA' do
      subject { create(:county_council) }

      it "returns all and county/unitary services that are enabled" do
        expect(subject.provided_services).to match_array([all_service, county_service])
      end
    end

    context 'for a "unitary" LA' do
      subject { create(:unitary_council) }

      it "returns all, district/unitary, and county/unitary services that are enabled" do
        expect(subject.provided_services).to match_array([all_service, county_service, district_service])
      end
    end
  end

  describe "#tier" do
    it "is a string representation of the Tier" do
      local_authority = create(:district_council)
      expect(local_authority.tier).to eql "district"
    end
  end

  describe "#active?" do
    it "is false for authorities that have passed their end date" do
      local_authority = create(:district_council)
      local_authority.active_end_date = Time.zone.now - 1.year
      expect(local_authority.active?).to be false
    end

    it "is true for authorities that have not passed their end date" do
      local_authority = create(:district_council)
      local_authority.active_end_date = Time.zone.now + 1.year
      expect(local_authority.active?).to be true
    end

    it "is true for authorities that have no end date" do
      local_authority = create(:district_council)
      expect(local_authority.active?).to be true
    end
  end

  describe ".find_current_by_slug" do
    it "returns nil if not found" do
      expect(LocalAuthority.find_current_by_slug("fake-cc")).to be nil
    end

    it "returns the authority if found and active" do
      local_authority = create(:district_council)
      expect(LocalAuthority.find_current_by_slug(local_authority.slug)).to eq local_authority
    end

    it "returns the succeeded_by authority if the authority is inactive" do
      succeeded_by_authority = create(:county_council)
      local_authority = create(:district_council, succeeded_by_local_authority: succeeded_by_authority, active_end_date: Time.zone.now - 1.year)
      expect(LocalAuthority.find_current_by_slug(local_authority.slug)).to eq succeeded_by_authority
    end
  end

  describe ".find_current_by_local_custodian_code" do
    it "returns nil if not found" do
      expect(LocalAuthority.find_current_by_local_custodian_code("fake-lcc")).to be nil
    end

    it "returns the authority if found and active" do
      local_authority = create(:district_council)
      expect(LocalAuthority.find_current_by_local_custodian_code(local_authority.local_custodian_code)).to eq local_authority
    end

    it "returns the succeeded_by authority if the authority is inactive" do
      succeeded_by_authority = create(:county_council)
      local_authority = create(:district_council, succeeded_by_local_authority: succeeded_by_authority, active_end_date: Time.zone.now - 1.year)
      expect(LocalAuthority.find_current_by_local_custodian_code(local_authority.local_custodian_code)).to eq succeeded_by_authority
    end
  end

  describe "#update_broken_link_count" do
    it "updates the broken_link_count" do
      link = create(:link, status: "broken")
      local_authority = link.local_authority
      expect { local_authority.update_broken_link_count }
        .to change { local_authority.broken_link_count }
        .from(0).to(1)
    end

    it "ignores unchecked links" do
      local_authority = create(:local_authority, broken_link_count: 1)
      create(:link, local_authority:, status: "pending")
      expect { local_authority.update_broken_link_count }
        .to change { local_authority.broken_link_count }
        .from(1).to(0)
    end

    it "ignores broken links that are not provided by the local_authority" do
      disabled_service_link = create(:link_for_disabled_service, status: "broken")
      local_authority = disabled_service_link.local_authority

      expect { local_authority.update_broken_link_count }
        .to_not(change { local_authority.broken_link_count })
    end
  end

  describe "External Content" do
    context "with an active council" do
      it "should update the external content when altered" do
        WebMock.reset!
        subject = build(:local_authority, content_id: SecureRandom.uuid)
        stub_publishing_api_for_subject(subject)
        subject.save!
        WebMock.reset!

        subject.homepage_url = "https://www.example.com/active-council"
        stubs = stub_publishing_api_for_subject(subject)
        subject.save!

        expect(stubs.first).to have_been_requested.once
        expect(stubs.last).to have_been_requested.once
      end

      it "should unpublish the external content when the council is retired" do
        WebMock.reset!
        subject = build(:local_authority, content_id: SecureRandom.uuid)
        stub_publishing_api_for_subject(subject)
        subject.save!
        WebMock.reset!

        subject.active_end_date = Time.zone.now - 1.day
        stub = stub_unpublish_for_subject(subject)
        subject.save!

        expect(stub).to have_been_requested.once
      end
    end

    context "with a retired council" do
      it "should unpublish the external content when altered" do
        WebMock.reset!
        subject = build(:local_authority, active_end_date: Time.zone.now - 1.day, content_id: SecureRandom.uuid)
        stub_publishing_api_for_subject(subject)
        stub_unpublish_for_subject(subject)
        subject.save!
        WebMock.reset!

        subject.homepage_url = "https://www.example.com/retired-council"
        stub = stub_unpublish_for_subject(subject)
        subject.save!

        expect(stub).to have_been_requested.once
      end
    end
  end
end
