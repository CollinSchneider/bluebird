class AddColumnsToMigration < ActiveRecord::Migration
  def change
    add_column :milestones, :goal, :string
    add_reference :milestones, :product, index: true
  end
end
