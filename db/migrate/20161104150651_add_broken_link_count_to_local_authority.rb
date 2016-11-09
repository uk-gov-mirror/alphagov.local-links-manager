class AddBrokenLinkCountToLocalAuthority < ActiveRecord::Migration[5.0]
  def up
    add_column :local_authorities, :broken_link_count, :integer, default: 0

    LocalAuthority.all.map(&:update_broken_link_count)
  end

  def down
    remove_column :local_authorities, :broken_link_count
  end
end
