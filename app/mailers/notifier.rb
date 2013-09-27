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
      @next_reading_1 = "Please go to" + link_to 'HomeBloodPressure.co.uk', new_user_session_path + "to take a pair of blood pressure readings."
      @next_reading_2 = "So, please go to <%= link_to 'HomeBloodPressure.co.uk', new_user_session_path %> to take a pair of blood pressure readings."
    elsif ampm == 'am'
      @next_reading_1 = "Please go to <%= link_to 'HomeBloodPressure.co.uk', new_user_session_path %> to take another pair of blood pressure readings this evening."
      @next_reading_2 = "So, this evening, please go to <%= link_to 'HomeBloodPressure.co.uk', new_user_session_path %> to take another pair of blood pressure readings."
    else
      @next_reading_1 = "Please go to" + link_to 'HomeBloodPressure.co.uk', new_user_session_path + "to take another pair of blood pressure readings tomorrow morning."
      @next_reading_2 = "So, tomorrow morning, please go to" + link_to 'HomeBloodPressure.co.uk', new_user_session_path + "to take another pair of blood pressure readings."
    end

    mail to: user.email, subject: "Welcome to HomeBloodPressure.co.uk"
  end
end
