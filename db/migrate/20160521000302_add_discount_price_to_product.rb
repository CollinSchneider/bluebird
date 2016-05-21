class AddDiscountPriceToProduct < ActiveRecord::Migration
  def change
    add_column :products, :discount, :string
  end
end
