class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.integer :lgsl_code
      t.string :label

      t.timestamps null: false
    end
  end
end
