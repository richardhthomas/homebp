class Notifier < ActionMailer::Base
  default from: "richard.thomas@itamus.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.sign_up.subject
  #
  def sign_up(email)
    @greeting = "Hi " + email

    mail to: "richardhthomas@yahoo.com", subject: "Welcome to HomeBloodPressure.co.uk"
  end
end
