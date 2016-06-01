class LocalAuthority < ActiveRecord::Base
  validates :gss, :snac, uniqueness: true
  validates :gss, :name, :snac, :tier, presence: true
  validates :homepage_url, non_blank_url: true, allow_blank: true
  validates :tier, inclusion: { in: %w(county district unitary),
    message: "%{value} is not an allowed tier" }

  has_many :links

  def provided_services
    Service.for_tier(self.tier).enabled
  end

  def hostname
    URI.parse(self.homepage_url).host
  end
end
