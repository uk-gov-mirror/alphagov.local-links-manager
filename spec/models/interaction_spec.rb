require 'rails_helper'

RSpec.describe Interaction, type: :model do
  before(:each) do
    create(:interaction)
  end

  it { is_expected.to validate_presence_of(:lgil_code) }
  it { is_expected.to validate_presence_of(:label) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_uniqueness_of(:lgil_code) }
  it { is_expected.to validate_uniqueness_of(:label) }
  it { is_expected.to validate_uniqueness_of(:slug) }

  it { is_expected.to have_many(:service_interactions) }
end
