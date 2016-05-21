class AddStatusToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :status, :string
  end
end
