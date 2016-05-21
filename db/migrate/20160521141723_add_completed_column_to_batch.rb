class AddCompletedColumnToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :completed_status, :string
  end
end
