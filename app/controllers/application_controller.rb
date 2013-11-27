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
  
  def set_date_ampm
    if session[:date] == nil
      session[:date] = Date.today #.to_s(:db) Removed this to allow date arithmetic (Was converting to string - not sure why I did this)
      if DateTime.now.seconds_since_midnight < 50400 #now 2pm is the start of pm!
        session[:ampm] = "am"
      else
        session[:ampm] = "pm"
      end
      session[:date_for_bp_entry] = session[:date]
      session[:ampm_for_bp_entry] = session[:ampm]
      
      @bp_entry_datetime = {}
      @bp_entry_datetime[:date] = session[:date]
      @bp_entry_datetime[:ampm] = session[:ampm]
    end
  end
  
  def reset_session
    session[:temp_user_id] = nil
    session[:date] = nil
    session[:ampm] = nil
    session[:reading_counter] = nil
    session[:average_bp_given] = nil
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
    reset_session
    root_path
  end
  
  def after_sign_in_path_for(resource)
    account_router_path
  end
  
  #return the number of average bp readings in the set
  def batch_average_bp_count
    active_user.average_bps.count
  end
  
  # define the average BP for the current batch of readings as well as the coordinates for the graphic display
  def batch_average_bp
    @bp_batch = active_user.average_bps
    @average_sysbp = @bp_batch.average(:sysbp)
    @average_diabp = @bp_batch.average(:diabp)
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
  
  def set_old_bp_datetime
    if (session[:date] == @bp_entry_datetime[:date]) && (session[:ampm] == @bp_entry_datetime[:ampm])
      @old_bp_datetime = ""
    elsif (session[:date] - @bp_entry_datetime[:date]).to_i > 1
      if @bp_entry_datetime[:ampm] == "am"
        @old_bp_datetime = "the morning of " + @bp_entry_datetime[:date].to_s
      else
        @old_bp_datetime = "the evening of " + @bp_entry_datetime[:date].to_s
      end
    elsif (session[:date] - @bp_entry_datetime[:date]).to_i == 1
      if @bp_entry_datetime[:ampm] == "am"
        @old_bp_datetime = "yesterday morning"
      else
        @old_bp_datetime = "yesterday evening"
      end
    else
      @old_bp_datetime = "this morning"
    end
  end
  
  def collect_bp_entry_datetime
    if @bp_entry_datetime == nil #check this hasn't been set by set_date_ampm already (in which case they are new to the site and there won't be any params)
      @bp_entry_datetime = {}
      @bp_entry_datetime[:date] = params[:date]
      @bp_entry_datetime[:ampm] = params[:ampm]
    end
  end
  
end
