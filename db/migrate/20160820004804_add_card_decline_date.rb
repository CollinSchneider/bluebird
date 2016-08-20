class AddCardDeclineDate < ActiveRecord::Migration
  def change
    add_column :commits, :card_decline_date, :datetime
  end
end
