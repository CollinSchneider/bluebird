class AddUuids < ActiveRecord::Migration
  def change
    add_column :users, :uuid, :string
    add_column :products, :uuid, :string
    add_column :commits, :uuid, :string
  end
end
