class RemoveAddressIdentifier < ActiveRecord::Migration
  def change
    remove_column :shipping_addresses, :address_id
  end
end
