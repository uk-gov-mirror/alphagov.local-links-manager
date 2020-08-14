class AddTierToServices < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :tier, :string
  end
end
