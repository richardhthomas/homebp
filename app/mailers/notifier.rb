class Notifier < ActionMailer::Base
  default from: "richard.thomas@itamus.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.sign_up.subject
  #
  def sign_up
    @greeting = "Hi " + current_user.email

    mail to: "richardhthomas@yahoo.com", subject: "Welcome to HomeBloodPRessure.co.uk"
  end
end
