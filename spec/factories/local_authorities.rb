FactoryGirl.define do
  factory :local_authority do
    sequence(:name) { |n| "Local Authority Name #{n}" }
    sequence(:gss) { |n| "S%08i" % n }
    sequence(:snac) { |n| "%02iQC" % n }
    tier "unitary"
    slug { name.parameterize }
    homepage_url "http://www.angus.gov.uk"
  end
end
