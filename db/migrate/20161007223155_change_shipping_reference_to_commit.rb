class ChangeShippingReferenceToCommit < ActiveRecord::Migration
  def change
    remove_column :shippings, :commit_id
    add_reference :commits, :shipping
  end
end
