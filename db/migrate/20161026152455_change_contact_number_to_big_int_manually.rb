class ChangeContactNumberToBigIntManually < ActiveRecord::Migration
  def change
    remove_column :companies, :contact_number
    add_column :companies, :contact_number, :integer, limit: 8
  end
end
