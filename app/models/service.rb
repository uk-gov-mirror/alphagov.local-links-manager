class Service < ActiveRecord::Base
  validates :lgsl_code, :label, presence: true, uniqueness: true
  validates :tier, inclusion: { in: %w{all county/unitary district/unitary}, allow_nil: true }

  has_many :service_interactions

  def provided_by?(authority)
    case tier
    when nil
      false
    when 'all'
      true
    else
      tiers.include? authority.tier
    end
  end

private

  def tiers
    tier.split('/')
  end
end
