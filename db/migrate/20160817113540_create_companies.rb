class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.references :user, index: true, foreign_key: true
      t.string :company_name
      t.string :company_key
      t.string :bio

      t.timestamps null: false
    end
  end
end
