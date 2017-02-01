class UpdateCommitSalesDefaults < ActiveRecord::Migration
  def change
    change_column :commits, :sale_amount, :float, :default => 0.0
    change_column :commits, :sale_amount_with_fees, :float, :default => 0.0
  end
end
