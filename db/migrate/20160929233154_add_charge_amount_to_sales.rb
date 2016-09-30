class AddChargeAmountToSales < ActiveRecord::Migration
  def change
    add_column :sales, :charge_amount, :float
  end
end
