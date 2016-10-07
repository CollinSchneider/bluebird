require 'sendgrid-ruby'
include SendGrid
require 'json'
class BlueBirdEmail

  COLLIN_EMAIL = "collin@bluebird.club"
  SALES_EMAIL = "sales@bluebird.club"
  SUPPORT_EMAIL = "support@bluebird.club"

  def self.test_email
    from = Email.new(email: SALES_EMAIL)
    subject = 'Hello World from the SendGrid Ruby Library!'
    to = Email.new(email: 'collin@jastr.co')
    content = Content.new(type: 'text/plain', value: 'Hello, Email!')
    mail = Mail.new(from, subject, to, content)
    binding.pry
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    binding.pry
    response = sg.client.mail._('send').post(request_body: json_mail)
    binding.pry
    puts response.status_code
    puts response.body
    puts response.headers
  end

  def self.send_email(from_email, to_email, subject, content)
    data = JSON.parse('{
      "personalizations": [
        {
          "to": [
            {
              "email": "collin.thomas.schneider@gmail.com"
            }
          ],
          "subject": "Hello World from the SendGrid Ruby Library!"
        }
      ],
      "from": {
        "email": "test@bluebird.club"
      },
      "content": [
        {
          "type": "text/plain",
          "value": "Hello, Email!"
        }
      ]
    }')

    # email.from = SendGrid::Email.new(email: from_email)
    # email.subject = subject
    #
    # per = SendGrid::Personalization.new
    # per.to = SendGrid::Email.new(email: to_email)
    #
    # email.personalizations = per
    #
    # email.contents = SendGrid::Content.new(type: 'text/plain', value: content)
    # email.contents = Content.new(type: 'text/html', value: content)

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])

    response = sg.client.mail._('send').post(request_body: data)
  end

  def self.retailer_welcome_email(user)
    controller = ActionController::Base.new()
    content = controller.render_to_string(:layout => 'mailer', :template => '/mailer/retailer_welcome_email.html.erb',
      :locals => {
        :@user => user
    })
    self.send_email(COLLIN_EMAIL, user.email, "Welcome to BlueBird.club, #{user.first_name}", content)
  end

  def wholesaler_welcome_email(user)
    controller = ActionController::Base.new()
    content = controller.render_to_string(:layout => 'mailer', :template => '/mailer/wholesaler_welcome_email.html.erb',
      :locals => {
        :@user => user
    })
    self.send_email(COLLIN_EMAIL, user.email, "Welcome to BlueBird.club, #{user.first_name}", content)
  end

  def wholesaler_needs_attention(user, product)
    controller = ActionController::Base.new()
    content = controller.render_to_string(:layout => 'mailer', :template => '/mailer/wholesaler_needs_attention.html.erb',
      :locals => {
        :@user => user,
        :@product => product
    })
    self.send_email(SALES_EMAIL, user.email, "Your move, #{user.first_name}", content)
  end

  def wholesaler_discount_hit(user, product)
    controller = ActionController::Base.new()
    content = controller.render_to_string(:layout => 'mailer', :template => '/mailer/wholesaler_discount_hit.html.erb',
      :locals => {
        :@user => user,
        :@product => product
    })
    self.send_email(SALES_EMAIL, user.email, "Your sales are in, #{user.first_name}", content)
  end

  def retailer_sale_shipped(user, tracking_carrier, tracking_code, tracking_delivery_date, tracking_url)
    controller = ActionController::Base.new()
    content = controller.render_to_string(:layout => 'mailer', :template => '/mailer/retailer_sale_shipped.html.erb',
      :locals => {
        :@user => user,
        :@tracking_carrier => tracking_carrier,
        :@tracking_code => tracking_code,
        :@tracking_delivery_date => tracking_delivery_date,
        :@tracking_url => tracking_url
    })
    self.send_email(SALES_EMAIL, user.email, "Your order is on the way, #{user.first_name}", content)
  end

  def retailer_declined_card_sale_shipped(user, tracking_carrier, tracking_code, tracking_delivery_date, tracking_url, charge)
      controller = ActionController::Base.new()
      content = controller.render_to_string(:layout => 'mailer', :template => '/mailer/retailer_declined_card_sale_shipped.html.erb',
        :locals => {
          :@user => user,
          :@tracking_carrier => tracking_carrier,
          :@tracking_code => tracking_code,
          :@tracking_delivery_date => tracking_delivery_date,
          :@tracking_url => tracking_url,
          :@charge => charge
      })
      self.send_email(SALES_EMAIL, user.email, "Your sales are in, #{user.first_name}", content)
  end

  def retailer_discount_hit(user, commit, product)
    controller = ActionController::Base.new()
    content = controller.render_to_string(:layout => 'mailer', :template => '/mailer/retailer_discount_hit.html.erb',
      :locals => {
        :@user => user,
        :@product => product,
        :@commit => commit
    })
    self.send_email(SALES_EMAIL, user.email, "Your savings are in, #{user.first_name}", content)
  end

  def retailer_discount_missed(user, product)
    controller = ActionController::Base.new()
    content = controller.render_to_string(:layout => 'mailer', :template => '/mailer/retailer_discount_missed.html.erb',
      :locals => {
        :@user => user,
        :@product => product
    })
    self.send_email(SALES_EMAIL, user.email, "BlueBird.club results", content)
  end

  def retailer_product_extended(user, product)
    controller = ActionController::Base.new()
    content = controller.render_to_string(:layout => 'mailer', :template => '/mailer/retailer_product_extended.html.erb',
      :locals => {
        :@user => user,
        :@product => product
    })
    self.send_email(SALES_EMAIL, user.email, "Product Update from BlueBird.club", content)
  end

  def forgot_password(user)
    controller = ActionController::Base.new()
    content = controller.render_to_string(:layout => 'mailer', :template => '/mailer/forgot_password.html.erb',
      :locals => {
        :@user => user
    })
    self.send_email(SUPPORT_EMAIL, user.email, "BlueBird.club reset password", content)
  end

  def card_declined(user, commit, card)
    controller = ActionController::Base.new()
    content = controller.render_to_string(:layout => 'mailer', :template => '/mailer/card_declined.html.erb',
      :locals => {
        :@user => user,
        :@card => card,
        :@commit => commit
    })
    self.send_email(SALES_EMAIL, user.email, "BlueBird.club Credit Card Error", content)
  end

  def wholesaler_full_price_email(commit, user)
    controller = ActionController::Base.new()
    content = controller.render_to_string(:layout => 'mailer', :template => '/mailer/wholesaler_full_price_email.html.erb',
      :locals => {
        :@user => user,
        :@commit => commit
    })
    self.send_email(SALES_EMAIL, user.email, "New BlueBird.club Purchase Order!", content)
  end

  def retailer_full_price_email(commit, user)
    controller = ActionController::Base.new()
    content = controller.render_to_string(:layout => 'mailer', :template => '/mailer/retailer_full_price_email.html.erb',
      :locals => {
        :@user => user,
        :@commit => commit
    })
    self.send_email(SALES_EMAIL, user.email, "BlueBird.club Purchase Confirmation", content)
  end

end
