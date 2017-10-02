class AddStatusIndexToLinks < ActiveRecord::Migration[5.0]
  def change
    add_index :links, :status
  end
end
