class AddFullPriceToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :full_price, :boolean
  end
end
