class AddDefaultWholesalerStatValues < ActiveRecord::Migration
  def change
    change_column :wholesaler_stats, :total_number_ratings, :integer, default: 0
    change_column :wholesaler_stats, :total_rating, :integer, default: 0
    change_column :wholesaler_stats, :total_shipments, :integer, default: 0
    change_column :wholesaler_stats, :total_shipping_difference, :integer, default: 0
  end
end
