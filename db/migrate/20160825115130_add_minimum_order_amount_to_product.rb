class AddMinimumOrderAmountToProduct < ActiveRecord::Migration
  def change
    add_column :products, :minimum_order, :integer
  end
end
