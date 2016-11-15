class CreateTierAndServiceTier < ActiveRecord::Migration[5.0]
  def change
    create_table :service_tiers do |t|
      t.integer :tier_id, null: false, index: true
    end

    add_reference :service_tiers, :service, null: false, index: true, foreign_key: true

    add_column :local_authorities, :tier_id, :integer, index: true
  end
end
