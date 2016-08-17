class CreateProductTokens < ActiveRecord::Migration
  def change
    create_table :product_tokens do |t|
      t.references :product, index: true, foreign_key: true
      t.string :token
      t.datetime :expiration_datetime

      t.timestamps null: false
    end
  end
end
