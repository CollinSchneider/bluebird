class AddProductVariantPhoto < ActiveRecord::Migration
  def change
    add_attachment :product_variants, :image
  end
end
