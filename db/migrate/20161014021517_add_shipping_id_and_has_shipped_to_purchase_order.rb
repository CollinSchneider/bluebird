class AddShippingIdAndHasShippedToPurchaseOrder < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :shipping_id, :string
    add_column :purchase_orders, :has_shipped, :boolean
  end
end
