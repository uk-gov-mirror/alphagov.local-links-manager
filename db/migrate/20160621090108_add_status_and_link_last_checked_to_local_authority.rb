class AddStatusAndLinkLastCheckedToLocalAuthority < ActiveRecord::Migration
  def change
    add_column :local_authorities, :status, :string
    add_column :local_authorities, :link_last_checked, :datetime
  end
end
