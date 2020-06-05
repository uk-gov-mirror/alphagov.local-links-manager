class AddDefaultToAnalytics < ActiveRecord::Migration[6.0]
  def up
    change_column :links, :analytics, :integer, default: 0
  end

  def down
    change_column :links, :analytics, :integer, default: nil
  end
end
