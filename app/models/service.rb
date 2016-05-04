class Service < ActiveRecord::Base
  validates :lgsl_code, :label, presence: true, uniqueness: true
end
