FactoryGirl.define do
  factory :interaction do
    sequence(:lgil_code) { |n| n }
    sequence(:label) { |n| "Interaction Label #{n}" }
    slug { label.parameterize }
  end
end
