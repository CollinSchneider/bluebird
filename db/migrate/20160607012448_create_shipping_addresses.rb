class CreateShippingAddresses < ActiveRecord::Migration
  def change
    create_table :shipping_addresses do |t|
      t.references :user, index: true, foreign_key: true
      t.string :address_id

      t.timestamps null: false
    end
  end
end
