class AddShippedOnDateToShipping < ActiveRecord::Migration
  def change
    add_column :shippings, :shipped_on, :timestamp
  end
end
