class AddEndAndStartTimeToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :start_time, :datetime
    add_column :batches, :end_time, :datetime
  end
end
