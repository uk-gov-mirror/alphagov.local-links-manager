FactoryBot.define do
  factory :local_authority do
    sequence(:name) { |n| "Local Authority Name #{n}" }
    sequence(:gss) { |n| format("S%<n>08i", n: n) }
    sequence(:snac) { |n| format("%<n>02iQC", n: n) }
    tier_id { Tier.unitary }
    slug { name.parameterize }
    homepage_url { "http://www.angus.gov.uk" }
    status { nil }
    link_last_checked { nil }
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
