class CreateWholesalers < ActiveRecord::Migration
  def change
    create_table :wholesalers do |t|
      t.references :user, index: true, foreign_key: true
      t.string :stripe_id
      
      t.timestamps null: false
    end
  end
end
