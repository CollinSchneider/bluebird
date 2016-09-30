class AddWholesalerIdToCommits < ActiveRecord::Migration
  def change
    add_reference :commits, :wholesaler
  end
end
