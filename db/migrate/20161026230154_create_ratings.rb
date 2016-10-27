class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.string :comment
      t.float :rating
      t.references :sale

      t.timestamps null: false
    end
  end
end
