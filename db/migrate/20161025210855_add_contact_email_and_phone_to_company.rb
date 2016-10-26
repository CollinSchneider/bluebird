class AddContactEmailAndPhoneToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :contact_number, :integer
    add_column :companies, :contact_email, :string
  end
end
