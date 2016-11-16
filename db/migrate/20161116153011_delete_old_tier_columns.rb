class DeleteOldTierColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :local_authorities, :tier
    remove_column :services, :tier
  end
end
