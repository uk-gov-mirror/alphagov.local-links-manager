class AllowNullSnac < ActiveRecord::Migration[7.0]
  def change
    change_column_null :local_authorities, :snac, true
  end
end
