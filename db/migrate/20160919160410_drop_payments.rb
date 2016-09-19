class DropPayments < ActiveRecord::Migration
  def change
    drop_table :milestones
    drop_table :product_features
    drop_table :product_images
    drop_table :full_price_commits
    drop_table :payments
  end
end
