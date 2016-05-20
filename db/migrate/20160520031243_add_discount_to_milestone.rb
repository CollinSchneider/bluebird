class AddDiscountToMilestone < ActiveRecord::Migration
  def change
    add_column :milestones, :discount, :string
  end
end
