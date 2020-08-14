class AddEnabledColumnToService < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :enabled, :boolean, default: false, null: false
  end
end
