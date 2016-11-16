class Service < ApplicationRecord
  validates :lgsl_code, :label, :slug, presence: true, uniqueness: true

  has_many :service_interactions
  has_many :interactions, through: :service_interactions
  has_many :service_tiers

  scope :for_tier, ->(tier_id) {
    Service
      .joins(:service_tiers)
      .where(service_tiers: { tier_id: tier_id })
  }

  scope :enabled, -> { where(enabled: true) }

  def tiers
    service_tiers.pluck(:tier_id).map { |t_id| Tier.as_string(t_id) }
  end

  def update_broken_link_count
    update_attribute(
      :broken_link_count,
      Link.for_service(self).have_been_checked.currently_broken.count
    )
  end
end
