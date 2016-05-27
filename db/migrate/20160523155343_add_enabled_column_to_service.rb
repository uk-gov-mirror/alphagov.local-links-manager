class AddEnabledColumnToService < ActiveRecord::Migration
  def change
    add_column :services, :enabled, :boolean, default: false, null: false
  end
end
