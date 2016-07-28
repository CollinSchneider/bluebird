class DropBatchIdInProducts < ActiveRecord::Migration
  def change
    remove_reference :products, :batch
  end
end
