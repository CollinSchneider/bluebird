class AddTrackingNumberAndCarrierToShipping < ActiveRecord::Migration
  def change
    add_column :shippings, :tracking_number, :string
    add_column :shippings, :carrier, :string
  end
end
