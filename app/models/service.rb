class Service < ApplicationRecord
  validates :lgsl_code, :label, :slug, presence: true, uniqueness: true
  validates :tier, inclusion: { in: %w{all county/unitary district/unitary}, allow_nil: true }

  has_many :service_interactions
  has_many :interactions, through: :service_interactions
  has_many :service_tiers

  scope :for_tier, ->(tier) {
    Service
      .joins(:service_tiers)
      .where(service_tiers: { tier_id: tier })
  }

  def tiers
    service_tiers.pluck(:tier_id)
  end

  scope :enabled, -> { where(enabled: true) }

  def update_broken_link_count
    update_attribute(
      :broken_link_count,
      Link.for_service(self).have_been_checked.currently_broken.count
    )
  end
end
