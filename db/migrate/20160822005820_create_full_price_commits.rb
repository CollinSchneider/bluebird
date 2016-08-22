class CreateFullPriceCommits < ActiveRecord::Migration
  def change
    create_table :full_price_commits do |t|
      t.references :product, index: true, foreign_key: true
      t.references :retailer, index: true, foreign_key: true
      t.string :uuid
      t.integer :amount
      t.string :stripe_charge_id
      t.boolean :card_declined
      t.datetime :card_decline_date
      t.string :declined_reason

      t.timestamps null: false
    end
  end
end
