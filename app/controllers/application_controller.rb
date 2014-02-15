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
  
  def tracker
    Mixpanel::Tracker.new("fa8043818be4dcbcce69f785817e7927")
  end
  
  def tracker_id
    active_user.id
  end
  
  def set_date_ampm
    if session[:date] == nil
      session[:date] = Date.today #.to_s(:db) Removed this to allow date arithmetic (Was converting to string - not sure why I did this)
      if DateTime.now.seconds_since_midnight < 50400 #now 2pm is the start of pm!
        session[:ampm] = "am"
      else
        session[:ampm] = "pm"
      end
    end
  end
  
  def reset_session
    session[:temp_user_id] = nil
    session[:date] = nil
    session[:ampm] = nil
    session[:average_bp_given] = nil
    session[:bp_entry_details] = nil
    session[:restart_done] = nil
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
    reset_session
    account_router_path
  end
  
  #return the number of average bp readings in the set
  def batch_average_bp_count
    active_user.average_bps.count(:sysbp)
  end
  
  def last_average_bp
    active_user.average_bps.last
  end
  
  # the 3 methods below are here rather than in current_bps_controller so that they are accessed from the info pages as well.
  def set_current_bps
    @n = @bp_entry_details[:datetime].to_i
    @current_bps = active_user.current_bps.where(:date => session[:bp_entry_details][:date][@n], :ampm => session[:bp_entry_details][:ampm][@n]).order("id")
  end
    
  def check_current_bp
    set_current_bps
    @key = @bp_entry_details[:reading_no].to_i - 1
    @current_bps[@key]
  end
    
  def collect_bp
    if check_current_bp
      @current_bp = check_current_bp
    else
      @current_bp = CurrentBp.new
    end
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
  
  def collect_bp_entry_details
    @bp_entry_details = {}
    if params.has_key?(:datetime) #check to see if params have been passed
      @n = params[:datetime].to_i
      if session[:bp_entry_details][:date][@n] != nil #check session variable exists with :datetime @n, otherwise user has gone back in browser and needs redirecting (I think this could only arise is a user goes back past the point of their own log-in and ends up on pages with URLs generated by a previous user). Or user could have put in arbitrary value for datetime in URL
        @bp_entry_details[:datetime] = params[:datetime]
        @bp_entry_details[:reading_no] = params[:reading_no]
        @bp_entry_details[:bp_given] = params[:bp_given]
      else
        redirect_to account_router_path
      end
    elsif batch_average_bp_count >= 1 && session[:bp_entry_details] != nil # array established but no params passed so set them up from the database (this will arise if user wanders off to other pages whilst giving BPs). Need to check for existence of session as otherwise router will trigger this logic when user first logs-in.
      if last_average_bp.ampm == "am"
        @date_needed = last_average_bp.date
        @ampm_index_modifier = 1
      else
        @date_needed = last_average_bp.date + 1
        @ampm_index_modifier = 0
      end
      session[:bp_entry_details][:date].each_with_index do |value, index|
        if value == @date_needed
          @bp_entry_details[:datetime] = index + @ampm_index_modifier
          # the logic below checks for the situation in which the user triggers this code but we don't want to increment to the next time slot as it is beyond the end of the session array and in the future!
          if @bp_entry_details[:datetime] > (session[:bp_entry_details][:date].count) - 1 # -1 as array starts from 0
            @bp_entry_details[:datetime] = (session[:bp_entry_details][:date].count) - 1
          end
          break
        end
      end
      @bp_entry_details[:reading_no] = '1'
    else # new to site so set things up for bp collection now with datetime set to now
      session[:bp_entry_details] = {}
      session[:bp_entry_details][:date] = []
      session[:bp_entry_details][:ampm] = []
      session[:bp_entry_details][:date][0] = session[:date]
      session[:bp_entry_details][:ampm][0] = session[:ampm]
      @bp_entry_details[:datetime] = 0 
      @bp_entry_details[:reading_no] = '1'
    end
  end
  
end
