class AddSlugToServices < ActiveRecord::Migration
  def up
    add_column :services, :slug, :string, unique: true

    Service.all.each do |service|
      service.slug = service.label.parameterize
      service.save!
    end

    change_column_null :services, :slug, false
  end

  def down
    remove_column :services, :slug
  end
end
