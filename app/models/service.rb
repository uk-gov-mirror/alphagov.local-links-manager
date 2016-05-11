class Service < ActiveRecord::Base
  validates :lgsl_code, :label, presence: true, uniqueness: true
  validates :tier, inclusion: { in: %w{all county/unitary district/unitary}, allow_nil: true }

  has_many :service_interactions
end
