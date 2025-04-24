class AddTitleToLinks < ActiveRecord::Migration[8.0]
  def change
    add_column :links, :title, :string
  end
end
