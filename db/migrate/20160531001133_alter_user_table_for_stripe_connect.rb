class AlterUserTableForStripeConnect < ActiveRecord::Migration
  def change
    remove_column :users, :stripe_customer_id
    add_column :users, :retailer_stripe_id, :string
    add_column :users, :wholesaler_stripe_id, :string
  end
end
