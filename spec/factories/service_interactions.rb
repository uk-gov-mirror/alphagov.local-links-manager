FactoryGirl.define do
  factory :service_interaction do
    association :interaction
    association :service
  end
end
