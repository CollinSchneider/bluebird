class AddRefundedToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :refunded, :boolean
  end
end
