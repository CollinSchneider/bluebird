class ChangeCommitsToReferencRetailers < ActiveRecord::Migration
  def change
    remove_column :commits, :user_id
    add_reference :commits, :retailer
    remove_column :products, :user_id
    add_reference :products, :wholesaler
  end
end
