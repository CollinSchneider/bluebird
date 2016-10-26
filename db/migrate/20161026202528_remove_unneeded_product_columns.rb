class RemoveUnneededProductColumns < ActiveRecord::Migration
  def change
    remove_column :products, :price
    remove_column :products, :discount
    remove_column :products, :retail_price
    remove_column :products, :total_bluebird_fee
    remove_column :products, :quantity
  end
end
