class AddParentLocalAuthorityIdToLocalAuthorities < ActiveRecord::Migration
  def change
    add_column :local_authorities, :parent_local_authority_id, :integer
  end
end
