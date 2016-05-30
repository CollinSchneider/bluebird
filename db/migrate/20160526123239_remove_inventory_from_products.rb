class RemoveInventoryFromProducts < ActiveRecord::Migration
  def change
    remove_column :products, :quantity
  end
end
