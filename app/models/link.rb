class Link < ActiveRecord::Base
  belongs_to :local_authority
  belongs_to :service_interaction

  has_one :service, through: :service_interaction
  has_one :interaction, through: :service_interaction

  validates :local_authority, :service_interaction, presence: true
  validates :service_interaction_id, uniqueness: { scope: :local_authority_id }
  validates :url, presence: true, non_blank_url: true
end
