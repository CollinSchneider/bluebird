class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.references :user, index: true, foreign_key: true
      t.datetime :end_time

      t.timestamps null: false
    end
  end
end
