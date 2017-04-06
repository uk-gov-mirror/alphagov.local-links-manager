class AddLinkErrorsAndLinkWarningsToLocalAuthority < ActiveRecord::Migration[5.0]
  def change
    add_column :local_authorities, :link_errors, :json
    add_column :local_authorities, :link_warnings, :json
  end
end
