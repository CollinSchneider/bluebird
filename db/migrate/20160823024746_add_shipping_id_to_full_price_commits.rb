class AddShippingIdToFullPriceCommits < ActiveRecord::Migration
  def change
    add_column :full_price_commits, :shipping_id, :string
  end
end
