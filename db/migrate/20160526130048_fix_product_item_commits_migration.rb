class FixProductItemCommitsMigration < ActiveRecord::Migration
  def change
    remove_column :commits, :product_item_id_id
    add_reference :commits, :product_item, reference: true
  end
end
