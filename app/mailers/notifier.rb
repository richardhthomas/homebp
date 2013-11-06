class Notifier < ActionMailer::Base
  include Devise::Mailers::Helpers
  
  default from: "admin@HomeBloodPressure.co.uk"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.sign_up.subject
  #
  
  def confirmation_instructions(record, opts={})
    devise_mail(record, :confirmation_instructions)
  end

  def reset_password_instructions(record, opts={})
    devise_mail(record, :reset_password_instructions)
  end

  def unlock_instructions(record, opts={})
    devise_mail(record, :unlock_instructions)
  end
  
  def sign_up(user, ampm)
    @greeting = "Hi " + user.email
    if ampm.nil?
      @when_next_reading = "as soon as you can"
      @a_another_reading = "a"
    elsif ampm == 'am'
      @when_next_reading = "this evening"
      @a_another_reading = "another"
    else
      @when_next_reading = "tomorrow morning"
      @a_another_reading = "another"
    end

    mail to: user.email, subject: "Welcome to HomeBloodPressure.co.uk"
  end
  
  def contact_us(message)
    @name = message.name
    @email = message.email
    @content = message.content
    mail to: "admin@HomeBloodPressure.co.uk", subject: "HomeBloodPressure.co.uk contact us"
  end
  
  def admin_mail(admin_message)
    @greeting = admin_message.greeting
    @content = admin_message.content
    mail to:, subject: admin_message.subject, bcc: admin_message.email
  end
end
