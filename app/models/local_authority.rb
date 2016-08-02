class LocalAuthority < ActiveRecord::Base
  after_update :reset_time_and_status, if: :homepage_url_changed?

  validates :gss, :snac, :slug, uniqueness: true
  validates :gss, :name, :snac, :tier, :slug, presence: true
  validates :homepage_url, non_blank_url: true, allow_blank: true
  validates :tier, inclusion: { in: %w(county district unitary),
    message: "%{value} is not an allowed tier" }

  has_many :links
  belongs_to :parent_local_authority, foreign_key: :parent_local_authority_id, class_name: "LocalAuthority"

  def provided_services
    Service.for_tier(self.tier).enabled
  end

private

  def reset_time_and_status
    self.update_columns(status: nil, link_last_checked: nil)
  end
end
