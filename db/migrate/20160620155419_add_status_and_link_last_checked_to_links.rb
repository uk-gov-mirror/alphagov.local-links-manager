class AddStatusAndLinkLastCheckedToLinks < ActiveRecord::Migration
  def change
    add_column :links, :status, :string
    add_column :links, :link_last_checked, :datetime
  end
end
