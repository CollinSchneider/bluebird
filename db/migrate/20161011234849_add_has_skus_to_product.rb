class AddHasSkusToProduct < ActiveRecord::Migration
  def change
    add_column :products, :has_skus, :boolean
  end
end
