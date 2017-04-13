class AddGovukSlugAndTitleToServiceInteractions < ActiveRecord::Migration[5.0]
  def change
    add_column :service_interactions, :govuk_slug, :string, unique: true
    add_column :service_interactions, :govuk_title, :string
    add_column :service_interactions, :live, :boolean

    add_index :service_interactions, :govuk_slug
  end
end
