class AddBatchToProduct < ActiveRecord::Migration
  def change
    add_reference :products, :batch, index: true
  end
end
