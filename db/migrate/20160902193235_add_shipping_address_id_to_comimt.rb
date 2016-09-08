class AddShippingAddressIdToComimt < ActiveRecord::Migration
  def change
    add_reference :commits, :shipping_address
  end
end
