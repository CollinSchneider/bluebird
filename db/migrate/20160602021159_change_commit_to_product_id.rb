class ChangeCommitToProductId < ActiveRecord::Migration
  def change
    remove_column :commits, :product_item_id
    add_reference :commits, :product, index: true
  end
end
