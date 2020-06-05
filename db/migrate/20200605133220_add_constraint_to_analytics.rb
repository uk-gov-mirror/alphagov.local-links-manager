class AddConstraintToAnalytics < ActiveRecord::Migration[6.0]
  def up
    change_column_null :links, :analytics, false, 0
  end

  def down
    change_column_null :links, :analytics, true
  end
end
