class CreateFavoriteSellers < ActiveRecord::Migration
  def change
    create_table :favorite_sellers do |t|
      t.references :retailer
      t.references :wholesaler

      t.timestamps null: false
    end
  end
end
