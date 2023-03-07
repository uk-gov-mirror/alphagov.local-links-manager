class AddSucceededByLocalAuthorityIdToLocalAuthority < ActiveRecord::Migration[7.0]
  def change
    add_reference :local_authorities, :succeeded_by_local_authority, type: :integer
  end
end
