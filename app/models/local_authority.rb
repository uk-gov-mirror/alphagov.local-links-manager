class LocalAuthority < ActiveRecord::Base
  validates :gss, :snac, uniqueness: true
  validates :gss, :name, :snac, :tier, presence: true
  validates :homepage_url, format: { with: URI.regexp }, allow_blank: true
  validates :tier, inclusion: { in: %w(county district unitary),
    message: "%{value} is not an allowed tier" }

  def provided_services
    Service.for_tier(self.tier)
  end
end
