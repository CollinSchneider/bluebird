class FixProductsUserReference < ActiveRecord::Migration
  def change
    remove_column :products, :user_id
    add_reference :products, :user, index: true
  end
end
