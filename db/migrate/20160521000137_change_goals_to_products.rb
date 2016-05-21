class ChangeGoalsToProducts < ActiveRecord::Migration
  def change
    remove_column :milestones, :discount
  end
end
