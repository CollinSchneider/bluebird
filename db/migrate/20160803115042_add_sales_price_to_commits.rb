class AddSalesPriceToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :sale_amount, :string
  end
end
