FactoryGirl.define do
  factory :interaction do
    lgil_code 0
    label "Applications for service"
    slug { label.parameterize }
  end
end
