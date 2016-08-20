class AddApprovedToWholesalers < ActiveRecord::Migration
  def change
    add_column :wholesalers, :approved, :boolean
  end
end
