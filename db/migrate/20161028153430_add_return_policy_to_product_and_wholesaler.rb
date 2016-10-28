class AddReturnPolicyToProductAndWholesaler < ActiveRecord::Migration
  def change
    add_reference :products, :return_policy
    add_reference :wholesalers, :return_policy
  end
end
