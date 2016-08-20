class CreateProductFeatures < ActiveRecord::Migration
  def change
    create_table :product_features do |t|
      t.references :product, index: true, foreign_key: true
      t.string :feature

      t.timestamps null: false
    end
  end
end
