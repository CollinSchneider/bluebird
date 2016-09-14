class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :commit, index: true, foreign_key: true
      t.references :retailer, index: true, foreign_key: true
      t.references :wholesaler, index: true, foreign_key: true
      t.string :payment_type
      t.string :stripe_charge_id
      t.decimal :amount
      t.boolean :refunded
      t.boolean :card_failed
      t.timestamps :card_declined_date
      t.string :card_declined_reason

      t.timestamps null: false
    end
  end
end
