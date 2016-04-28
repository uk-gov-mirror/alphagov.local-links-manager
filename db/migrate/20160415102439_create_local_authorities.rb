class CreateLocalAuthorities < ActiveRecord::Migration
  def change
    create_table :local_authorities do |t|
      t.string :gss
      t.string :homepage_url
      t.string :name
      t.string :slug
      t.string :snac
      t.string :tier

      t.timestamps null: false
    end

    add_index :local_authorities, :gss, unique: true
    add_index :local_authorities, :snac, unique: true
  end
end
