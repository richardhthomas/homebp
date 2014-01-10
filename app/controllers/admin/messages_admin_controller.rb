class Admin::MessagesAdminController < Admin::AdminController
  def new_individual
    @admin_message = AdminMessage.new
    @admin_message_email = User.find(params[:id]).email
    @greeting = "Hello " + @admin_message_email
  end
  
  def new
    @admin_message = AdminMessage.new
    @emails = User.pluck(:email)
    @admin_message_email = @emails.join(", ")
    @greeting = "Hello from HomeBloodPressure.co.uk,"
  end
  
  def create
    @admin_message = AdminMessage.new(params[:admin_message])
    if @admin_message.valid?
      Notifier.admin_mail(@admin_message).deliver
      redirect_to admin_menu_path, notice: "Message sent!"
    else
      render Rails.application.routes.recognize_path(request.referer)[:action]
    end
  end
  
  def send_chase_user_for_bp
    #code goes here to define @emails as list of email of users with missed reading
      #define last time slot
    set_date_ampm
    if session[:ampm] == "am"
      @last_date = session[:date] - 1
      @last_ampm = "pm"
    else
      @last_date = session[:date]
      @last_ampm = "am"
    end
      #search for all users who have an average_bp recorded but without a reading for the last time slot
      #format them into a suitable bcc list
    Notifier.chase_user_for_bp(@emails).deliver
    redirect_to admin_menu_path, notice: "Message sent!"
  end
end