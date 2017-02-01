class AddDefaultFalseFullPriceToCommits < ActiveRecord::Migration
  def change
    change_column :commits, :full_price, :boolean, :default => false
  end
end
