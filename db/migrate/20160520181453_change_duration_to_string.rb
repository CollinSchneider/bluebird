class ChangeDurationToString < ActiveRecord::Migration
  def change
    remove_column :batches, :duration
    add_column :batches, :duration, :string
  end
end
