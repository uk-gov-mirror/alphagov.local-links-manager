require 'rails_helper'

RSpec.describe LocalAuthority, type: :model do
  describe 'validations' do
    before(:each) do
      FactoryGirl.create(:local_authority)
    end

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:gss) }
    it { should validate_presence_of(:snac) }
    it { should validate_presence_of(:tier) }
    it { should validate_presence_of(:slug) }

    it { should validate_uniqueness_of(:gss) }
    it { should validate_uniqueness_of(:snac) }
    it { should validate_uniqueness_of(:slug) }

    describe 'homepage_url' do
      it { should allow_value('http://foo.com').for(:homepage_url) }
      it { should allow_value('https://foo.com/path/file.html').for(:homepage_url) }

      it { should_not allow_value('foo.com').for(:homepage_url) }
      it { is_expected.to allow_value(nil).for(:homepage_url) }
    end

    describe 'tier' do
      %w(county district unitary).each do |tier|
        it { should allow_value(tier).for(:tier) }
      end

      it { should_not allow_value(nil).for(:tier) }
      it { should_not allow_value('country').for(:tier) }
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:links) }
  end

  describe '#provided_services' do
    let!(:all_service) { FactoryGirl.create(:service, tier: 'all', lgsl_code: 1, label: 'All Service', enabled: true) }
    let!(:county_service) { FactoryGirl.create(:service, tier: 'county/unitary', lgsl_code: 2, label: 'County Service', enabled: true) }
    let!(:district_service) { FactoryGirl.create(:service, tier: 'district/unitary', lgsl_code: 3, label: 'District Service', enabled: true) }
    let!(:nil_service) { FactoryGirl.create(:service, tier: nil, lgsl_code: 4, label: 'Nil Service', enabled: true) }
    let!(:disabled_service) { FactoryGirl.create(:service, tier: 'district/unitary', lgsl_code: 5, label: 'Disabled District Service', enabled: false) }
    subject { FactoryGirl.build(:local_authority) }

    context 'for a "district" LA' do
      before { subject.tier = 'district' }
      it 'returns all and district/unitary services that are enabled' do
        expect(subject.provided_services).to match_array([all_service, district_service])
      end
    end

    context 'for a "county" LA' do
      before { subject.tier = 'county' }
      it 'returns all and county/unitary services that are enabled' do
        expect(subject.provided_services).to match_array([all_service, county_service])
      end
    end

    context 'for a "unitary" LA' do
      before { subject.tier = 'unitary' }
      it 'returns all, district/unitary, and county/unitary services that are enabled' do
        expect(subject.provided_services).to match_array([all_service, county_service, district_service])
      end
    end

    describe "after_update" do
      it "sets the homepage url status and last checked time to nil if the homepage url is updated" do
        @local_authority = FactoryGirl.create(:local_authority, status: "200", link_last_checked: Time.now)
        @local_authority.homepage_url = "http://example.com"
        @local_authority.save!
        expect(@local_authority.status).to be_nil
        expect(@local_authority.link_last_checked).to be_nil
      end
    end

    describe "calculate_count_of_broken_links" do
      it "calculates the correct number of broken for the local authority" do
        local_authority = FactoryGirl.create(:local_authority)
        FactoryGirl.create(:link, :with_service_interaction, local_authority: local_authority, status: 500)
        expect { local_authority.calculate_count_of_broken_links }.to change { local_authority.broken_link_count }.from(0).to(1)
      end
    end
  end
end
