FactoryGirl.define do
  factory :service do
    lgsl_code 1152
    label "Abandoned shopping trolleys"
    slug { label.parameterize }
    enabled false
  end
end
