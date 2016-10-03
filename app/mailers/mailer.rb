class Mailer < ApplicationMailer
  default from: 'info@bluebird.club'

  def retailer_welcome_email(user)
    @user = user
    email_with_name = %("#{@user.full_name}" <#{@user.email}>)
    mail(to: @user.email, subject: "Welcome to BlueBird.club, #{@user.first_name}")
  end

  def wholesaler_welcome_email(user)
    @user = user
    email_with_name = %("#{@user.full_name}" <#{@user.email}>)
    mail(to: @user.email, subject: "Welcome to BlueBird.club, #{@user.first_name}")
  end

  def wholesaler_needs_attention(user, product)
    @user = user
    @product = product
    email_with_name = %("#{@user.full_name}" <#{@user.email}>)
    mail(to: @user.email, subject: "Your move, #{@user.first_name}")
  end

  def wholesaler_discount_hit(user, product)
    @user = user
    @product = product
    email_with_name = %("#{@user.full_name}" <#{@user.email}>)
    mail(to: @user.email, subject: "The sales are in, #{@user.first_name}")
  end

  def retailer_sale_shipped(user, tracking_carrier, tracking_code, tracking_delivery_date, tracking_url)
    @user = user
    @tracking_carrier = tracking_carrier
    @tracking_code = tracking_code
    @tracking_delivery_date = tracking_delivery_date
    @tracking_url = tracking_url
    email_with_name = %("#{@user.full_name}" <#{@user.email}>)
    mail(to: @user.email, subject: "Your order is on the way, #{@user.first_name}")
  end

  def retailer_declined_card_sale_shipped(user, tracking_carrier, tracking_code, tracking_delivery_date, tracking_url, charge)
      @user = user
      @tracking_carrier = tracking_carrier
      @tracking_code = tracking_code
      @tracking_delivery_date = tracking_delivery_date
      @tracking_url = tracking_url
      @charge = charge
      email_with_name = %("#{@user.full_name}" <#{@user.email}>)
      mail(to: @user.email, subject: "Your order is on the way, but we need some info")
  end

  def retailer_discount_hit(user, commit, product)
    @user = user
    @commit = commit
    @product = product
    email_with_name = %("#{@user.full_name}" <#{@user.email}>)
    mail(to: @user.email, subject: "Your savings are in, #{@user.first_name}")
  end

  def retailer_discount_missed(user, product)
    @user = user
    @product = product
    email_with_name = %("#{@user.full_name}" <#{@user.email}>)
    mail(to: @user.email, subject: "BlueBird.club results")
  end

  def retailer_product_extended(user, product)
    @user = user
    @product = product
    email_with_name = %("#{@user.full_name}" <#{@user.email}>)
    mail(to: @user.email, subject: "Product Update from BlueBird.club")
  end

  def forgot_password(user)
    @user = user
    email_with_name = %("#{@user.full_name}" <#{@user.email}>)
    mail(to: @user.email, subject: "BlueBird password reset")
  end

  def card_declined(user, commit, card)
    @user = user
    @card = card
    @commit = commit
    email_with_name = %("#{@user.full_name}" <#{@user.email}>)
    mail(to: @user.email, subject: "BlueBird credit card error")
  end

  def wholesaler_full_price_email(commit, user)
    @commit = commit
    @user = user
    email_with_name = %("#{@user.full_name}" <#{@user.email}>)
    mail(to: @user.email, subject: "New Purchase Order!")
  end

  def retailer_full_price_email(commit, user)
    @commit = commit
    @user = user
    email_with_name = %("#{@user.full_name}" <#{@user.email}>)
    mail(to: @user.email, subject: "Purchase Confirmation")
  end

end
