class CreateServiceInteractions < ActiveRecord::Migration[5.0]
  def change
    create_table :service_interactions do |t|
      t.integer :service_id
      t.integer :interaction_id

      t.timestamps null: false
    end
  end
end
