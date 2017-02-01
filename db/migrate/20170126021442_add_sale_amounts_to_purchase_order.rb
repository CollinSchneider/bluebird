class AddSaleAmountsToPurchaseOrder < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :sale_amount, :float
    add_column :purchase_orders, :sale_amount_with_fees, :float
  end
end
