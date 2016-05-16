class AddTierToServices < ActiveRecord::Migration
  def change
    add_column :services, :tier, :string
  end
end
