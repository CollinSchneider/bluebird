class AddBlueBirdFeeCollectionToProduct < ActiveRecord::Migration
  def change
    add_column :products, :total_bluebird_fee, :float
    remove_column :products, :percent_discount
    add_column :products, :percent_discount, :float
  end
end
