class AddAvgRating < ActiveRecord::Migration
  def change
    add_column :wholesalers, :average_rating, :float, default: 0.0
  end
end
