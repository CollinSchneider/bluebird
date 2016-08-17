class AddContactableToUsers < ActiveRecord::Migration
  def change
    add_column :users, :contactable, :boolean
    add_column :users, :phone_number, :string
  end
end
