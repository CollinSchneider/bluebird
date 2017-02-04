class AddStripeCustomerIdToWholesaler < ActiveRecord::Migration
  def change
    add_column :wholesalers, :stripe_customer_id, :string
  end
end
