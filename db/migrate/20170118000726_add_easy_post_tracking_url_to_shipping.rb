class AddEasyPostTrackingUrlToShipping < ActiveRecord::Migration
  def change
    add_column :shippings, :easypost_tracking_url, :string
  end
end
