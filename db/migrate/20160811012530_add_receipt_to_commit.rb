class AddReceiptToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :pdf_generated, :boolean
  end
end
