class Admin::MessagesAdminController < ApplicationController
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
      render "new_individual"
    end
  end
end