class LocalAuthority < ApplicationRecord
  after_update :reset_time_and_status, if: :homepage_url_changed?

  validates :gss, :snac, :slug, uniqueness: true
  validates :gss, :name, :snac, :slug, presence: true
  validates :homepage_url, non_blank_url: true, allow_blank: true
  validates :tier_id, presence: true, inclusion:
    {
      in: [Tier.unitary, Tier.district, Tier.county],
      message: "%{value} is not a valid tier"
    }

  has_many :links
  belongs_to :parent_local_authority, foreign_key: :parent_local_authority_id, class_name: "LocalAuthority"
  has_many :service_tiers, foreign_key: :tier_id, primary_key: :tier_id
  has_many :services, through: :service_tiers

  def tier
    Tier.as_string(tier_id)
  end

  def provided_services
    services.enabled
  end

  def self.provides_service(service)
    tier_field = LocalAuthority.arel_table[:tier]
    case service.tier
    when 'all'
      self
    when 'county/unitary'
      where(tier_field.not_eq('district'))
    when 'district/unitary'
      where(tier_field.not_eq('county'))
    end
  end

  def update_broken_link_count
    update_attribute(
      :broken_link_count,
      links.have_been_checked.currently_broken.count
    )
  end

  def to_param
    self.slug
  end

private

  def reset_time_and_status
    self.update_columns(status: nil, link_last_checked: nil)
  end
end
