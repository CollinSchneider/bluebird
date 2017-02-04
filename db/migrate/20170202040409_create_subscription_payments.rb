class CreateSubscriptionPayments < ActiveRecord::Migration
  def change
    create_table :subscription_payments do |t|
      t.references :wholesaler, index: true, foreign_key: true
      t.boolean :completed, default: false
      t.string :card_id
      t.float :charge_amount
      t.datetime :due_at
      t.boolean :card_failed, default: false
      t.datetime :card_failed_at

      t.timestamps null: false
    end
  end
end
