class AddCreatedAtToServiceTiers < ActiveRecord::Migration[5.0]
  def change
    add_column :service_tiers, :created_at, :datetime
  end
end
