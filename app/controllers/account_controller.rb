class AccountController < ApplicationController
  before_action :set_cache_buster
  before_action :authenticate_user!, only: [:set_bp_entry_datetime, :readings_due, :restart_needed, :submit_readings]
  before_action :set_date_ampm
  before_action :collect_bp_entry_details, only: [:set_bp_entry_datetime, :readings_due, :is_bp_set_completable, :restart_needed, :home]
  before_action :batch_average_bp, only: [:home, :readings_due]
  before_action :set_batch_average_bp_count, only: [:home, :readings_due]
  
  def home
    @current_average_bp = active_user.average_bps.last
    if @current_average_bp == nil
      redirect_to account_router_path
    end
  end
  
  def router
    if user_signed_in?
      #Check if any readings at all, if not ask to take reading now
      if batch_average_bp_count < 1
        redirect_to new_current_bp_path#(@bp_entry_details)
    
      # check if has full set of bp readings
      elsif batch_average_bp_count >=8
        redirect_to account_submit_readings_path
    
      #check if they are too early for next reading
      elsif (session[:date] == last_average_bp.date && session[:ampm] == last_average_bp.ampm)
        redirect_to account_home_path#(@bp_entry_details)
    
      #so otherwise, readings are due
      else
        redirect_to account_set_bp_entry_datetime_path#(@bp_entry_details)
      end
      
    else
      if batch_average_bp_count < 1 # not signed in and no readings - go to landing page
        redirect_to blood_pressure_treatment_path#(@bp_entry_details) # need to pass bp_entry_details here so if user goes back in browser to landing page, they are kept alive.
      
      else # not signed in but given a reading - go to home page
        redirect_to account_home_path
      end
    end 
  end
  
  def set_bp_entry_datetime
    if session[:average_bp_given] == nil # if not started giving readings define the date and ampm slots required in session array and set to first time slot
      @session_bp_entry_details_date = last_average_bp.date
      @session_bp_entry_details_ampm = last_average_bp.ampm
      @time_slots_count = ((session[:date] - last_average_bp.date).to_i) * 2
      if last_average_bp.ampm == "am" # add another bp for collection if still need pm reading from date of @last_average_bp
        @time_slots_count += 1
      end
      if session[:ampm] == "am" # subtract a bp for collection if only need am readings from today's date
        @time_slots_count -= 1
      end
      if @time_slots_count > 13 # limit to 7 days of readings (1 will always have been taken by this point, so 13 rather than 14)
        @time_slots_count = 13
      end
      
      @time_slots_count.times do |n|
        if @session_bp_entry_details_ampm == "am"
          @session_bp_entry_details_ampm = "pm"
        else
          @session_bp_entry_details_date += 1
          @session_bp_entry_details_ampm = "am"
        end
        session[:bp_entry_details][:date][n] = @session_bp_entry_details_date
        session[:bp_entry_details][:ampm][n] = @session_bp_entry_details_ampm
      end
      @bp_entry_details[:datetime] = 0
      @bp_entry_details[:reading_no] = '1'
    end
    redirect_to account_readings_due_path(@bp_entry_details)
  end
  
  def readings_due
  end
  
  def is_bp_set_completable
    session[:average_bp_given] = 'skipped' # set :average_bp_given so that on returning to set_bp_entry_datetime, the session variables are not redfined
    
    # put blank entry in database for current time slot
    @n = @bp_entry_details[:datetime].to_i
    @average_bp = active_user.average_bps.build
    @average_bp.date = session[:bp_entry_details][:date][@n]
    @average_bp.ampm = session[:bp_entry_details][:ampm][@n]
    @average_bp.save
    
    @first_average_bp = active_user.average_bps.first
    @n = @bp_entry_details[:datetime].to_i
    if ((7-((session[:bp_entry_details][:date][@n] - @first_average_bp.date).to_i)) * 2) < (8 - batch_average_bp_count)
      redirect_to account_restart_needed_path#(@bp_entry_details)
    else # can continue to gather BPs, but first increment the timeslot
      @bp_entry_details[:datetime] = @bp_entry_details[:datetime].to_i + 1
      @bp_entry_details[:reading_no] = '1'
      
      redirect_to account_readings_due_path(@bp_entry_details)
    end
  end
  
  def restart_needed
  end
  
  def restart
    reset_session
    active_user.average_bps.each do |average_bp|
      average_bp.destroy
    end
    active_user.current_bps.each do |current_bp|
      current_bp.destroy
    end
    redirect_to account_router_path
  end
  
  def submit_readings
    
  end
  
  
  private
  
  def set_batch_average_bp_count
    @batch_average_bp_count = batch_average_bp_count
  end

end