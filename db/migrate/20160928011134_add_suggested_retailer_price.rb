class AddSuggestedRetailerPrice < ActiveRecord::Migration
  def change
    add_column :products, :retail_price, :float
  end
end
