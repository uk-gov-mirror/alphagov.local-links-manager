class AddStatusAndLinkLastCheckedToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :status, :string
    add_column :links, :link_last_checked, :datetime
  end
end
