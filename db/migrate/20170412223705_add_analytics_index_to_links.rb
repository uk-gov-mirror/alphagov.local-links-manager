class AddAnalyticsIndexToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :analytics, :integer

    add_index :links, :analytics
  end
end
