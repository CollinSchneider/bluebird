class AddContactableColumnsToWholesaler < ActiveRecord::Migration
  def change
    remove_column :users, :contactable
    add_column :wholesalers, :contactable_by_phone, :boolean
    add_column :wholesalers, :contactable_by_email, :boolean
  end
end
