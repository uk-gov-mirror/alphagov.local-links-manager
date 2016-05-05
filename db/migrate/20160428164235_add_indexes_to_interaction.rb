class AddIndexesToInteraction < ActiveRecord::Migration
  def change
    add_index :interactions, :lgil_code, unique: true
    add_index :interactions, :label, unique: true
    change_column_null :interactions, :lgil_code, false
    change_column_null :interactions, :label, false
  end
end
