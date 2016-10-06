class ChangeStringsToFloats < ActiveRecord::Migration
  def change
    remove_column :products, :price
    add_column :products, :price, :float
    remove_column :products, :discount
    add_column :products, :discount, :float
    remove_column :products, :price
    add_column :products, :price, :float
    remove_column :products, :goal
    add_column :products, :goal, :float
    remove_column :products, :current_sales
    add_column :products, :current_sales, :float
  end
end
