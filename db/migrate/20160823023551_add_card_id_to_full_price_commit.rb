class AddCardIdToFullPriceCommit < ActiveRecord::Migration
  def change
    add_column :full_price_commits, :card_id, :string
  end
end
