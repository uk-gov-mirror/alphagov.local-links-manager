class CreateInteractions < ActiveRecord::Migration
  def change
    create_table :interactions do |t|
      t.integer :lgil_code
      t.string :label

      t.timestamps null: false
    end
  end
end
