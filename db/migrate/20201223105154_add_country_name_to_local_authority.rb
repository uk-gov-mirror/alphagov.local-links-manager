class AddCountryNameToLocalAuthority < ActiveRecord::Migration[6.0]
  def change
    add_column :local_authorities, :country_name, :string
  end
end
