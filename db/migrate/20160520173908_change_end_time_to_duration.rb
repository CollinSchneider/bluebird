class ChangeEndTimeToDuration < ActiveRecord::Migration
  def change
    remove_column :batches, :end_time
    add_column :batches, :duration, :string
  end
end
