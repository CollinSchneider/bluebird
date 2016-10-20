class AddFullPriceToPurchaseOrder < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :full_price, :boolean, default: false
  end
end
