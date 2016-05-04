class ServiceInteraction < ActiveRecord::Base
  validates :service_id, :interaction_id, presence: true
  validates :service_id, uniqueness: { scope: :interaction_id }

  belongs_to :service
  belongs_to :interaction
end
