class ChangeRetailersToApproved < ActiveRecord::Migration
  def change
    remove_column :retailers, :accepted
    add_column :retailers, :approved, :boolean, default: true
  end
end
