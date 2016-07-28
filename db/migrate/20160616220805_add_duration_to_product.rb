class AddDurationToProduct < ActiveRecord::Migration
  def change
    add_column :products, :duration, :string
  end
end
