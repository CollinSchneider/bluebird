class DropUnneededCommitColumns < ActiveRecord::Migration
  def change
    remove_column :commits, :shipping_charge_id
    remove_column :commits, :shipping_id
    remove_column :commits, :declined_reason
    remove_column :commits, :card_declined
    remove_column :commits, :card_decline_date
    remove_column :commits, :pdf_generated
    remove_column :commits, :stripe_charge_id
  end
end
