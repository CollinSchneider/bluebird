class AddSalesWithFees < ActiveRecord::Migration
  def change
    add_column :products, :current_sales_with_fees, :float
    add_column :commits, :sale_amount_with_fees, :float
  end
end
