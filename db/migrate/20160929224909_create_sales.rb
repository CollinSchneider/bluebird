class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.references :commit, index: true, foreign_key: true
      t.references :retailer, index: true, foreign_key: true
      t.references :wholesaler, index: true, foreign_key: true
      t.float :sale_amount
      t.string :stripe_charge_id
      t.boolean :card_failed
      t.timestamps :card_failed_date
      t.string :card_failed_reason

      t.timestamps null: false
    end
  end
end
