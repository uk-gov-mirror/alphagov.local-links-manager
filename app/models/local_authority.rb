class LocalAuthority < ApplicationRecord
  validates :gss, :slug, uniqueness: true
  validates :snac, uniqueness: true, allow_nil: true
  validates :gss, :name, :slug, presence: true
  validates :tier_id,
            presence: true,
            inclusion:
                {
                  in: [Tier.unitary, Tier.district, Tier.county],
                  message: "%{value} is not a valid tier",
                }

  has_many :links, dependent: :destroy
  belongs_to :parent_local_authority, class_name: "LocalAuthority", inverse_of: false, optional: true
  belongs_to :succeeded_by_local_authority, class_name: "LocalAuthority", inverse_of: false, optional: true
  has_many :service_tiers, foreign_key: :tier_id, primary_key: :tier_id, inverse_of: :local_authority, dependent: :restrict_with_error
  has_many :services, through: :service_tiers

  scope :link_last_checked_before,
        lambda { |last_checked|
          where("link_last_checked IS NULL OR link_last_checked < ?", last_checked)
        }

  scope :active, -> { where("active_end_date IS NULL OR active_end_date > ?", Time.zone.now) }

  validates :status, inclusion: { in: %w[ok broken caution pending] }, allow_nil: true

  def tier
    Tier.as_string(tier_id)
  end

  def provided_services
    services.enabled
  end

  # returns the Links for this authority,
  # for the enabled Services that this authority provides.
  def provided_service_links
    links.joins(:service).merge(provided_services)
  end

  def update_broken_link_count
    update(broken_link_count: provided_service_links.broken_or_missing.count)
  end

  def to_param
    slug
  end

  def redirect(to:)
    LocalAuthorityRedirector.call(from: self, to:)
  end

  def active?
    active_end_date.nil? || (active_end_date > Time.zone.now)
  end

  def self.find_current_by_slug(slug)
    la = find_by(slug:)
    return nil unless la
    return la if la.active?

    la.succeeded_by_local_authority
  end

  def self.find_current_by_local_custodian_code(local_custodian_code)
    la = find_by(local_custodian_code:)
    return nil unless la
    return la if la.active?

    la.succeeded_by_local_authority
  end
end
