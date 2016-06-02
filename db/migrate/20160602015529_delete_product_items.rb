class DeleteProductItems < ActiveRecord::Migration
  def change
    drop_table :product_items
  end
end
