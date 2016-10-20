class CreateSkus < ActiveRecord::Migration
  def change
    create_table :skus do |t|
      t.references :product, foreign_key: true, index: true
      t.references :product_variant, foreign_key: true, index: true
      t.references :product_sizing, foreign_key: true, index: true
      t.float :price
      t.float :discount_price
      t.float :suggested_retail

      t.timestamps null: false
    end
  end
end
