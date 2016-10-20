class AddHasShippedAndRefundedToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :sale_made, :boolean
    add_column :purchase_orders, :refunded, :boolean
  end
end
