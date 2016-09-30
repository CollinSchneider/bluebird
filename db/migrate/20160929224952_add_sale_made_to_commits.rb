class AddSaleMadeToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :sale_made, :boolean
  end
end
