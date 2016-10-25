class AddAcceptedToRetailers < ActiveRecord::Migration
  def change
    add_column :retailers, :accepted, :boolean, default: false
  end
end
