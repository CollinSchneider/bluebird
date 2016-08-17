class AddPercentDiscountToProduct < ActiveRecord::Migration
  def change
    add_column :products, :percent_discount, :string
  end
end
