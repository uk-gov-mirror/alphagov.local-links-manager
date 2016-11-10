class AddBrokenLinkCountToService < ActiveRecord::Migration[5.0]
  def up
    add_column :services, :broken_link_count, :integer, default: 0

    Service.all.map(&:update_broken_link_count)
  end

  def down
    remove_column :services, :broken_link_count
  end
end
