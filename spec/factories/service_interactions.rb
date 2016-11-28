FactoryGirl.define do
  factory :service_interaction do
    association :interaction
    association :service, :all_tiers
  end
end
