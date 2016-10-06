# Preview all emails at http://localhost:3000/rails/mailers/mailer
class MailerPreview < ActionMailer::Preview

  def wholesaler_welcome_email
    Mailer.wholesaler_welcome_email(User.find(Wholesaler.first.user_id))
  end

  def retailer_welcome_email
    Mailer.retailer_welcome_email(User.find(Retailer.first.user_id))
  end

end