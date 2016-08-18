class ChangeShippingToReferenceRetailer < ActiveRecord::Migration
  def change
    remove_column :shipping_addresses, :user_id
    add_reference :shipping_addresses, :retailer
  end
end
