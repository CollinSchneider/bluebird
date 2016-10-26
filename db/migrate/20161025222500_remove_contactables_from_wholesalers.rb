class RemoveContactablesFromWholesalers < ActiveRecord::Migration
  def change
    remove_column :wholesalers, :contactable_by_phone
    remove_column :wholesalers, :contactable_by_email
  end
end
