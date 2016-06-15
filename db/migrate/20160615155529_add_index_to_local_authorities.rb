class AddIndexToLocalAuthorities < ActiveRecord::Migration
  def change
    add_index :local_authorities, :slug, unique: true

    change_column_null :local_authorities, :gss, false
    change_column_null :local_authorities, :name, false
    change_column_null :local_authorities, :snac, false
    change_column_null :local_authorities, :slug, false
    change_column_null :local_authorities, :tier, false
  end
end
