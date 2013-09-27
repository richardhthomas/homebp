class Notifier < ActionMailer::Base
  default from: "richard.thomas@itamus.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.sign_up.subject
  #
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
end
