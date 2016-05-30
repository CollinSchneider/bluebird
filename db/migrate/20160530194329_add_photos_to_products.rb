class AddPhotosToProducts < ActiveRecord::Migration
  def change
    add_attachment :products, :main_image
    add_attachment :products, :photo_two
    add_attachment :products, :photo_three
    add_attachment :products, :photo_four
    add_attachment :products, :photo_five
  end
end
