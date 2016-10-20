class AddInventoryToSkus < ActiveRecord::Migration
  def change
    add_column :skus, :inventory, :integer
  end
end
