class AddBatchToMilestone < ActiveRecord::Migration
  def change
    add_reference :milestones, :batch, index: true
  end
end
