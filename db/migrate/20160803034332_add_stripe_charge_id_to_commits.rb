class AddStripeChargeIdToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :stripe_charge_id, :string
  end
end
