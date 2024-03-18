class AddContentIdToLocalAuthorities < ActiveRecord::Migration[7.1]
  def change
    enable_extension "pgcrypto"

    add_column :local_authorities, :content_id, :uuid, default: "gen_random_uuid()"
    add_index :local_authorities, :content_id, unique: true
  end
end
