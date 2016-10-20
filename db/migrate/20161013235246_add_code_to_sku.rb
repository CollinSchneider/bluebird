class AddCodeToSku < ActiveRecord::Migration
  def change
    add_column :skus, :code, :string
  end
end
