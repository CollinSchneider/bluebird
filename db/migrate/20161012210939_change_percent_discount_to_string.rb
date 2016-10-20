class ChangePercentDiscountToString < ActiveRecord::Migration
  def change
    remove_column :products, :percent_discount
    add_column :products, :percent_discount, :string
  end
end
