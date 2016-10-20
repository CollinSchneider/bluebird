class AddPriceWithFeeToSku < ActiveRecord::Migration
  def change
    add_column :skus, :price_with_fee, :float
  end
end
