require 'rails_helper'

RSpec.describe Link, type: :model do
  describe 'validations' do
    subject(:link) { FactoryGirl.create(:link) }

    it { is_expected.to validate_presence_of(:local_authority) }
    it { is_expected.to validate_presence_of(:service_interaction) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_uniqueness_of(:service_interaction_id).scoped_to(:local_authority_id) }

    describe '#url' do
      it 'disallows urls without schemes' do
        is_expected.not_to allow_value('example.com').for(:url).with_message('is not a URL')
      end

      it 'disallows urls without a domain' do
        is_expected.not_to allow_value('com').for(:url).with_message('is not a URL')
      end

      it 'allows http urls' do
        is_expected.to allow_value('http://example.com').for(:url)
      end

      it 'allows https urls' do
        is_expected.to allow_value('https://example.com').for(:url)
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:local_authority) }
    it { is_expected.to belong_to(:service_interaction) }

    it { is_expected.to have_one(:service).through(:service_interaction) }
    it { is_expected.to have_one(:interaction).through(:service_interaction) }
  end
end
