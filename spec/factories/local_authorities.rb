FactoryGirl.define do
  factory :local_authority do
    sequence(:name) { |n| "Local Authority Name #{n}" }
    sequence(:gss) { |n| "S%08i" % n }
    sequence(:snac) { |n| "%02iQC" % n }
    tier "unitary"
    tier_id { Tier.unitary }
    slug { name.parameterize }
    homepage_url "http://www.angus.gov.uk"
    status nil
    link_last_checked nil
  end

  factory :district_council, parent: :local_authority do
    tier 'district'
    tier_id { Tier.district }
  end

  factory :unitary_council, parent: :local_authority do
    tier 'unitary'
    tier_id { Tier.unitary }
  end

  factory :county_council, parent: :local_authority do
    tier 'county'
    tier_id { Tier.county }
  end
end
