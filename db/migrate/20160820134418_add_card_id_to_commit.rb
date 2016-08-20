class AddCardIdToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :card_id, :string
  end
end
