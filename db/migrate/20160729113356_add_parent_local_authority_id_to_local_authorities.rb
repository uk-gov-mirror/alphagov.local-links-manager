class AddParentLocalAuthorityIdToLocalAuthorities < ActiveRecord::Migration[5.0]
  def change
    add_column :local_authorities, :parent_local_authority_id, :integer
  end
end
