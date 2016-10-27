class RenameWholesalerTotalOrders < ActiveRecord::Migration
  def change
    rename_column :wholesalers, :total_orders, :total_number_ratings
  end
end
