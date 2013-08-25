class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  
  
  private

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
  
  def get_temp_user
    TempUser.find(session[:temp_user_id])
  rescue ActiveRecord::RecordNotFound
    temp_user = TempUser.create
    session[:temp_user_id] = temp_user.id
    temp_user
  end
  
  def active_user
    if current_user
      current_user
    else
      get_temp_user
    end
  end
end
