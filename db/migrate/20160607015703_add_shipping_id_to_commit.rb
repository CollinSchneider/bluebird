class AddShippingIdToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :shipping_id, :string
  end
end
