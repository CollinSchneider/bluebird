class AddCardErrorToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :card_declined, :boolean
  end
end
