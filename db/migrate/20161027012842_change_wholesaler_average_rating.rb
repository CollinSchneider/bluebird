class ChangeWholesalerAverageRating < ActiveRecord::Migration
  def change
    remove_column :wholesalers, :average_rating
    add_column :wholesalers, :total_rating, :integer, default: 0.0
    add_column :wholesalers, :total_orders, :integer, default: 0.0
  end
end
