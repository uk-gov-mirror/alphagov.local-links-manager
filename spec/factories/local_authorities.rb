FactoryBot.define do
  factory :local_authority do
    sequence(:name) { |n| "Local Authority Name #{n}" }
    sequence(:gss) { |n| sprintf("S%<n>08i", n:) }
    sequence(:snac) { |n| sprintf("%<n>02iQC", n:) }
    sequence(:local_custodian_code) { |n| sprintf("%<n>04i", n:) }
    tier_id { Tier.unitary }
    slug { name.parameterize }
    homepage_url { "http://www.angus.gov.uk" }
    status { nil }
    link_last_checked { nil }
    country_name { "England" }
  end

  factory :district_council, parent: :local_authority do
    tier_id { Tier.district }
  end

  factory :unitary_council, parent: :local_authority do
    tier_id { Tier.unitary }
  end

  factory :county_council, parent: :local_authority do
    tier_id { Tier.county }
  end
end
