class AddDeclineReasonToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :declined_reason, :string
  end
end
