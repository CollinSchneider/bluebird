class AddShippingAmountToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :shipping_amount, :float
  end
end
