class ChangeCommitAmountToInteger < ActiveRecord::Migration
  def change
    remove_column :commits, :amount
    add_column :commits, :amount, :integer
  end
end
