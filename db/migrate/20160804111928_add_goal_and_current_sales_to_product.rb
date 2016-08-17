class AddGoalAndCurrentSalesToProduct < ActiveRecord::Migration
  def change
    add_column :products, :goal, :string
    add_column :products, :current_sales, :string
  end
end
