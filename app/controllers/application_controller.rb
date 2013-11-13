class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  ensure_security_headers
  
  
  protected
  
  def admin_required
    if (Rails.env == 'production' || Rails.env == 'development') #|| params[:admin_http]
      authenticate_or_request_with_http_basic do |user_name, password|
        user_name == 'admin' && password == '98Haz3llvill3Rd'
      end
    end
  end
  
  
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
  
  def after_sign_out_path_for(resource_or_scope)
    session[:temp_user_id] = nil #kill the temp_user in the session so the router doesn't rediscover it after signing out.
    session[:date] = nil
    session[:ampm] = nil
    root_path
  end
  
  def after_sign_in_path_for(resource)
    @count = active_user.average_bps.count # this is just a count of the number of BPs associated with the user
    if @count > 0
      static_pages_sign_in_msg_path
    else
      new_current_bp_path
    end
  end
  
  #return the number of average bp readings in the set
  def set_average_bp_count
    active_user.average_bps.count
  end
  
  # define the average BP for the current set of readings as well as the coordinates for the graphic display
  def set_average_bp
    @bp_set = active_user.average_bps
    @average_sysbp = @bp_set.average(:sysbp)
    @average_diabp = @bp_set.average(:diabp)
    if !@average_sysbp.nil?
      @sys_position = 70 + ((170 - @average_sysbp)*3)
      @dia_position = 70 + ((110 - @average_diabp)*4)
      if @sys_position < @dia_position
        @bp_position = @sys_position
      else
        @bp_position = @dia_position
      end
      if @bp_position < 70
        @bp_position = 70
      end
      if @bp_position > 250
        @bp_position = 250
      end
    end
  end
  
end
