class ChangedApprovedToUsersTable < ActiveRecord::Migration
  def change
    remove_column :wholesalers, :approved
    remove_column :retailers, :approved
    add_column :users, :approved, :boolean, default: false
  end
end
