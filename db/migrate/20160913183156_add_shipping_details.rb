class AddShippingDetails < ActiveRecord::Migration
  def change
    add_column :shipping_addresses, :street_address_one, :string
    add_column :shipping_addresses, :street_address_two, :string
    add_column :shipping_addresses, :city, :string
    add_column :shipping_addresses, :zip, :string
    add_column :shipping_addresses, :state, :string
  end
end
