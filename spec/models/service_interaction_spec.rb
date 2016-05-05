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
end
