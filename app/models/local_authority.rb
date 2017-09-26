class LocalAuthority < ApplicationRecord
  validates :gss, :snac, :slug, uniqueness: true
  validates :gss, :name, :snac, :slug, presence: true
  validates :tier_id, presence: true, inclusion:
    {
      in: [Tier.unitary, Tier.district, Tier.county],
      message: "%{value} is not a valid tier"
    }

  has_many :links
  belongs_to :parent_local_authority, foreign_key: :parent_local_authority_id, class_name: "LocalAuthority"
  has_many :service_tiers, foreign_key: :tier_id, primary_key: :tier_id
  has_many :services, through: :service_tiers

  scope :link_last_checked_before, -> (last_checked) {
    where("link_last_checked IS NULL OR link_last_checked < ?", last_checked)
  }

  validates :status, inclusion: { in: %w(ok broken caution pending) }, allow_nil: true

  def tier
    Tier.as_string(tier_id)
  end

  def provided_services
    services.enabled
  end

  # returns the Links for this authority,
  # for the enabled Services that this authority provides.
  def provided_service_links
    links.with_url.joins(:service).merge(provided_services)
  end

  def update_broken_link_count
    update_attribute(
      :broken_link_count,
      provided_service_links.have_been_checked.currently_broken.count
    )
  end

  def to_param
    self.slug
  end
end
