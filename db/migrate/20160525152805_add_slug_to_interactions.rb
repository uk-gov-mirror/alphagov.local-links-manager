class AddSlugToInteractions < ActiveRecord::Migration[5.0]
  def up
    add_column :interactions, :slug, :string, unique: true

    Interaction.all.each do |interaction|
      interaction.slug = interaction.label.parameterize
      interaction.save!
    end

    change_column_null :interactions, :slug, false
  end

  def down
    remove_column :interactions, :slug
  end
end
