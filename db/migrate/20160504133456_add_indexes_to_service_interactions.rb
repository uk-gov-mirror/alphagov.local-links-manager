class AddIndexesToServiceInteractions < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :service_interactions, :services
    add_foreign_key :service_interactions, :interactions

    add_index :service_interactions, %i[service_id interaction_id], unique: true
  end
end
