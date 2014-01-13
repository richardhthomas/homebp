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
  
  def chase_user_for_bp
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
    
    #search for all users who have an average_bp recorded, but without a reading for the last time slot
    @bcc_array = []
    @users = User.all
    @users.each do |user|
      if user.average_bps.exists?
        if !user.average_bps.exists?(:date => @last_date, :ampm => @last_ampm) #no need to check for bp from current time slot, as a blank date and ampm entry is put in the database when a reading is missed, so it isn't possible for a user to have a reading from the current time slot and not have an entry in the database from the previous time slot.
          @bcc_array.push(user.email)
        end
      end
    end
    @emails = @bcc_array.join(", ")

    Notifier.chase_user_for_bp(@emails).deliver
    redirect_to admin_menu_path, notice: "Message sent!"
  end
end