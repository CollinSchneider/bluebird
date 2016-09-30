class AddCardFailedDateToSalesAndShipping < ActiveRecord::Migration
  def change
    add_column :sales, :card_failed_date, :timestamp
    add_column :shippings, :card_failed_date, :timestamp
  end
end
