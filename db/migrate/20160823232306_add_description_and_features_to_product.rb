class AddDescriptionAndFeaturesToProduct < ActiveRecord::Migration
  def change
    add_column :products, :long_description, :string
    add_column :products, :feature_one, :string
    add_column :products, :feature_two, :string
    add_column :products, :feature_three, :string
    add_column :products, :feature_four, :string
    add_column :products, :feature_five, :string
  end
end
