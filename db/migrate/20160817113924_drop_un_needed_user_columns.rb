class DropUnNeededUserColumns < ActiveRecord::Migration
  def change
    remove_column :users, :user_type
    remove_column :users, :retailer_stripe_id
    remove_column :users, :wholesaler_stripe_id
    remove_column :users, :company_name
    remove_column :users, :key
    drop_table :stripe_credentials
  end
end
