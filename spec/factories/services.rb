FactoryGirl.define do
  factory :service do
    sequence(:lgsl_code) { |n| n }
    sequence(:label) { |n| "Service Label #{n}" }
    slug { label.parameterize }
    enabled false
  end
end
