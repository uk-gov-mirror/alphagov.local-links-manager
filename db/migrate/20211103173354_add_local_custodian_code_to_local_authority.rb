class AddLocalCustodianCodeToLocalAuthority < ActiveRecord::Migration[6.1]
  def change
    add_column :local_authorities, :local_custodian_code, :string
  end
end
