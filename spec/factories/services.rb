FactoryGirl.define do
  factory :service do
    sequence(:lgsl_code) { |n| n }
    sequence(:label) { |n| "Service Label #{n}" }
    slug { label.parameterize }
    enabled true
  end

  factory :disabled_service, parent: :service do
    enabled false
  end
end
