class ChangeCommitSaleAmountToFloat < ActiveRecord::Migration
  def change
    remove_column :commits, :sale_amount
    add_column :commits, :sale_amount, :float
  end
end
