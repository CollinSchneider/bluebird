class WholesalersController < ApplicationController

  def index
    authenticate_wholesaler
  end

end
