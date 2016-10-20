class ChangeDescriptionToShortDescription < ActiveRecord::Migration
  def change
    remove_column :products, :description
    add_column :products, :short_description, :string
  end
end
