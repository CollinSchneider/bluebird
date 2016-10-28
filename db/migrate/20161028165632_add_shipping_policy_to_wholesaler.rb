class AddShippingPolicyToWholesaler < ActiveRecord::Migration
  def change
    add_column :wholesalers, :shipping_policy, :string
  end
end
