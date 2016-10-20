class CreateProductSizings < ActiveRecord::Migration
  def change
    create_table :product_sizings do |t|
      t.references :product, foreign_key: true, index: true
      t.string :description

      t.timestamps null: false
    end
  end
end
