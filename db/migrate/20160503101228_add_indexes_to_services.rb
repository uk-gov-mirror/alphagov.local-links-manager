class AddIndexesToServices < ActiveRecord::Migration
  def change
    add_index :services, :lgsl_code, unique: true
    add_index :services, :label, unique: true
    change_column_null :services, :lgsl_code, false
    change_column_null :services, :label, false
  end
end
