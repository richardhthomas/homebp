class Admin::MessagesAdminController < ApplicationController
  def new(user)
    @admin_message = AdminMessage.new
    @admin_message.email = user.email
  end

  def create
    @admin_message = AdminMessage.new(params[:message])
    if @admin_message.valid?
      Notifier.admin_mail(@admin_message).deliver
      redirect_to admin_menu_path, notice: "Message sent!"
    else
      render "new"
    end
  end
end