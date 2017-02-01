class AddDefaultValuesToCommitsAndPurchaseOrders < ActiveRecord::Migration
  def change
    change_column :commits, :full_price, :boolean, :defulat => false
    change_column :commits, :status, :string, :default => 'live'
    change_column :commits, :sale_made, :boolean, :default => false
    change_column :commits, :refunded, :boolean, :default => false
    change_column :purchase_orders, :sale_made, :boolean, :default => false
    change_column :purchase_orders, :refunded, :boolean, :default => false
    change_column :purchase_orders, :has_shipped, :boolean, :default => false 
  end
end
