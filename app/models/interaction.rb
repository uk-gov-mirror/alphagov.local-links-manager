class Interaction < ActiveRecord::Base
  PROVIDING_INFORMATION_LGIL = 8

  validates :lgil_code, :label, :slug, presence: true, uniqueness: true

  has_many :service_interactions
  has_many :services, through: :service_interactions
end
