desc 'Migrate Tier data to new schema'
task migrate_tier: :environment do
  puts 'Migrating Local Authority Tiers'
  LocalAuthority.all.each do |local_authority|
    local_authority.tier_id = Tier.public_send(local_authority.tier)
    local_authority.save
    print '.'
  end

  puts
  puts 'Migrating Service tiers'
  Service.where.not(tier: nil).each do |service|
    case service.tier
    when 'district/unitary'
      ServiceTier.create(service: service, tier_id: Tier.district)
      ServiceTier.create(service: service, tier_id: Tier.unitary)
    when 'county/unitary'
      ServiceTier.create(service: service, tier_id: Tier.county)
      ServiceTier.create(service: service, tier_id: Tier.unitary)
    when 'all'
      ServiceTier.create(service: service, tier_id: Tier.county)
      ServiceTier.create(service: service, tier_id: Tier.unitary)
      ServiceTier.create(service: service, tier_id: Tier.district)
    end
    print '.'
  end
  puts
  puts 'Done'
end
