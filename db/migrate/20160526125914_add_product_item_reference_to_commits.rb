class AddProductItemReferenceToCommits < ActiveRecord::Migration
  def change
    remove_column :commits, :product_id
    add_reference :commits, :product_item, reference: true
  end
end
