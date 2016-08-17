class Api::ProductsController < ApiController

  def extend_product
    product = Product.find_by_uuid(params[:uuid])
    product.end_time = Time.now + 10.days
    product.status = 'live'
    if product.save(validate: false)
      product.commits.each do |commit|
        Mailer.retailer_product_extended(commit.user, product)
      end
      render :json => {
        success: true,
        product: product
      }
    else
      render :json => {
        success: false,
        errors: product.errors
      }
    end
  end

end
