class AddIndexesToServiceInteractions < ActiveRecord::Migration
  def change
    add_foreign_key :service_interactions, :services
    add_foreign_key :service_interactions, :interactions

    add_index :service_interactions, [:service_id, :interaction_id], unique: true 
  end
end
