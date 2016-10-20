class ChangePercentDiscountToFloat < ActiveRecord::Migration
  def change
    remove_column :products, :percent_discount
    add_column :products, :percent_discount, :float
  end
end
