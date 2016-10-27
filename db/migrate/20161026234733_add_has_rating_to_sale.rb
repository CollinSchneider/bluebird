class AddHasRatingToSale < ActiveRecord::Migration
  def change
    add_column :sales, :has_rating, :boolean, default: false
  end
end
