class CreateProductItems < ActiveRecord::Migration
  def change
    create_table :product_items do |t|
      t.string :description
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
