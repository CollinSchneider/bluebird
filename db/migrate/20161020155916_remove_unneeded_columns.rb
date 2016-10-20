class RemoveUnneededColumns < ActiveRecord::Migration
  def change
    remove_column :commits, :shipping_id
    remove_column :purchase_orders, :product_id
    remove_column :purchase_orders, :retailer_id
    remove_column :purchase_orders, :wholesaler_id
  end
end
