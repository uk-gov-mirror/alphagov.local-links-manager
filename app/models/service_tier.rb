class ServiceTier < ApplicationRecord
  belongs_to :service
  belongs_to :local_authority, foreign_key: :tier_id, primary_key: :tier_id, inverse_of: :local_authority
  validates :service_id, uniqueness: { scope: :tier_id }

  def self.create_tiers(tiers, service)
    tiers.each { |tier| ServiceTier.create(service: service, tier_id: tier) }
  end
end
