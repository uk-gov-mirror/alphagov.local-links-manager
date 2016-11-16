class ServiceTier < ApplicationRecord
  belongs_to :service
  belongs_to :local_authority, foreign_key: :tier_id, primary_key: :tier_id
end
