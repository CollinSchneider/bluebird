class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.references :sku, index: true, foreign_key: true
      t.references :commit, index: true, foreign_key: true
      t.references :product, index: true, foreign_key: true
      t.references :retailer, index: true, foreign_key: true
      t.references :wholesaler, index: true, foreign_key: true
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
