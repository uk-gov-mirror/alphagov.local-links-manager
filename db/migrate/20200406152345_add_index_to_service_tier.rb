class AddIndexToServiceTier < ActiveRecord::Migration[6.0]
  def change
    add_index :service_tiers, %i[service_id tier_id], unique: true
  end
end
