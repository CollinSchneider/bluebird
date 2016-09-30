class AddHasShippedToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :has_shipped, :boolean, default: false
  end
end
