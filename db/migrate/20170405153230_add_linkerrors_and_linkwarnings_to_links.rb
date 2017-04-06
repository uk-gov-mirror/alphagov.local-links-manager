class AddLinkerrorsAndLinkwarningsToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :link_errors, :json
    add_column :links, :link_warnings, :json
  end
end
