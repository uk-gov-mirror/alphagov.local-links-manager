def create_factory_service_tiers(service, tiers)
  tiers.each do |tier|
    service.service_tiers << ServiceTier.create(service: service, tier_id: tier)
  end
end

FactoryGirl.define do
  factory :service do
    sequence(:lgsl_code) { |n| n }
    sequence(:label) { |n| "Service Label #{n}" }
    slug { label.parameterize }
    enabled true

    trait :all_tiers do
      sequence(:label) { |n| "All Tiers #{n}" }
      after(:create) do |service|
        create_factory_service_tiers(service, [Tier.unitary, Tier.district, Tier.county])
      end
    end

    trait :district_unitary do
      sequence(:label) { |n| "District/Unitary #{n}" }
      after(:create) do |service|
        create_factory_service_tiers(service, [Tier.unitary, Tier.district])
      end
    end

    trait :county_unitary do
      sequence(:label) { |n| "County/Unitary #{n}" }
      after(:create) do |service|
        create_factory_service_tiers(service, [Tier.unitary, Tier.county])
      end
    end
  end

  factory :disabled_service, parent: :service do
    enabled false
  end
end
