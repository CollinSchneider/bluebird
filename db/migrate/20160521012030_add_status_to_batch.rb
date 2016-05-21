class AddStatusToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :status, :string
  end
end
