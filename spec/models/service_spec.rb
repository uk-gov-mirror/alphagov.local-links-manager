require 'rails_helper'

RSpec.describe Service, type: :model do
  before(:each) do
    FactoryGirl.create(:service)
  end

  it { is_expected.to validate_presence_of(:lgsl_code) }
  it { is_expected.to validate_presence_of(:label) }
  it { is_expected.to validate_uniqueness_of(:lgsl_code) }
  it { is_expected.to validate_uniqueness_of(:label) }

  it { is_expected.to have_many(:service_interactions) }
end
