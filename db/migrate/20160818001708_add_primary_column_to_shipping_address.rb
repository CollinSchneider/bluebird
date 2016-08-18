class AddPrimaryColumnToShippingAddress < ActiveRecord::Migration
  def change
    add_column :shipping_addresses, :primary, :boolean
  end
end
