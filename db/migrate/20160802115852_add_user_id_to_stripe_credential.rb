class AddUserIdToStripeCredential < ActiveRecord::Migration
  def change
    add_column :stripe_credentials, :stripe_user_id, :string
  end
end
