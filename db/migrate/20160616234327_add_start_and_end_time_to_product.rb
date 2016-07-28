class AddStartAndEndTimeToProduct < ActiveRecord::Migration
  def change
    add_column :products, :start_time, :datetime
    add_column :products, :end_time, :datetime
  end
end
