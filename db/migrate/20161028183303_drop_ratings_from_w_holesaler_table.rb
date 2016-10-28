class DropRatingsFromWHolesalerTable < ActiveRecord::Migration
  def change
    remove_column :wholesalers, :total_number_ratings
    remove_column :wholesalers, :total_rating
  end
end
