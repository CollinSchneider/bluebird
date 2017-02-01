class AddNumberStringsToTables < ActiveRecord::Migration
  def change
    add_column :commits, :number, :string
    add_column :shippings, :number, :string
    add_column :sales, :number, :string
    add_column :skus, :number, :string
    add_column :products, :number, :string
  end
end
