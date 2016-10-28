class CreateWholesalerStats < ActiveRecord::Migration
  def change
    create_table :wholesaler_stats do |t|
      t.references :wholesaler, index: true, foreign_key: true
      t.integer :total_number_ratings
      t.integer :total_rating
      t.integer :total_shipping_difference
      t.integer :total_shipments

      t.timestamps null: false
    end
  end
end
