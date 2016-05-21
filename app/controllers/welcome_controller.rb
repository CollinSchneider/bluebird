class WelcomeController < ApplicationController

  def shop
    # @products = Product.all
    @products = Product.where('status = ?', 'live')
  end

end
