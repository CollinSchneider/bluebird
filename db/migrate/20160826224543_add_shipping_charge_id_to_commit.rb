class AddShippingChargeIdToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :shipping_charge_id, :string
  end
end
