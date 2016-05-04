class Interaction < ActiveRecord::Base
  validates :lgil_code, :label, presence: true, uniqueness: true
end
