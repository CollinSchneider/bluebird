class ChangeWholesalerStatReference < ActiveRecord::Migration
  def change
    remove_column :wholesaler_stats, :wholesaler_id
    add_reference :wholesalers, :wholesaler_stat
  end
end
