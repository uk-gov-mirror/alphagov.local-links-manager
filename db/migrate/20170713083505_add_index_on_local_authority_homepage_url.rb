class AddIndexOnLocalAuthorityHomepageUrl < ActiveRecord::Migration[5.0]
  def change
    add_index :local_authorities, :homepage_url
  end
end
