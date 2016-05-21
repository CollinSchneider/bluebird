class WelcomeController < ApplicationController

  def shop
    @products = Product.where('status = ?', 'live')
  end

end
