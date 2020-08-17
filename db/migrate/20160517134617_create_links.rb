class CreateLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :links do |t|
      t.references :local_authority, index: true, foreign_key: true, null: false
      t.references :service_interaction, index: true, foreign_key: true, null: false
      t.string :url, null: false

      t.timestamps null: false
    end

    add_index :links, %i[local_authority_id service_interaction_id], unique: true
  end
end
