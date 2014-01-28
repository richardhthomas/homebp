class AccountController < ApplicationController
  before_action :set_cache_buster
  before_action :authenticate_user!, only: [:set_bp_entry_datetime, :readings_due, :restart_needed, :submit_readings]
  before_action :set_date_ampm
  before_action :collect_bp_entry_details, only: [:router, :set_bp_entry_datetime, :readings_due, :is_bp_set_completable]
  before_action :batch_average_bp, only: [:home, :readings_due]
  before_action :set_batch_average_bp_count, only: [:home, :readings_due]
  before_action :set_first_average_bp, only: [:router, :is_bp_set_completable]
  
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
        redirect_to new_current_bp_path(@bp_entry_details)
    
      # check if has full set of bp readings
      elsif batch_average_bp_count >=8
        redirect_to account_submit_readings_path
      
      #check if they need to restart
      elsif is_restart_needed(last_average_bp.date, last_average_bp.ampm) == true
        redirect_to account_restart_needed_path
    
      #check if they are too early for next reading
      elsif (session[:date] == last_average_bp.date && session[:ampm] == last_average_bp.ampm)
        redirect_to account_home_path
    
      #so otherwise, readings are due
      else
        redirect_to account_set_bp_entry_datetime_path(@bp_entry_details)
      end
      
    else
      if batch_average_bp_count < 1 # not signed in and no readings - go to landing page
        redirect_to info_path('home_page')
      
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
    @bp_entry_details[:bp_given] = 'skipped' # this ensures text is appropriate in the view for readings_due
    session[:average_bp_given] = 'skipped' # this ensures that session[:bp_entry_details] doesn't get redefined
    
    # put blank entry in database for current time slot
    @n = @bp_entry_details[:datetime].to_i
    @average_bp = active_user.average_bps.build
    @average_bp.date = session[:bp_entry_details][:date][@n]
    @average_bp.ampm = session[:bp_entry_details][:ampm][@n]
    @average_bp.save
    
    @first_average_bp = active_user.average_bps.first
    @n = @bp_entry_details[:datetime].to_i
    if is_restart_needed(session[:bp_entry_details][:date][@n], session[:bp_entry_details][:ampm][@n]) == true
      redirect_to account_restart_needed_path
    else # can continue to gather BPs, but first increment the timeslot
      @bp_entry_details[:datetime] = @bp_entry_details[:datetime].to_i + 1
      @bp_entry_details[:reading_no] = '1'
      redirect_to account_readings_due_path(@bp_entry_details)
    end
  end
  
  def restart_needed
    if session[:restart_done] == 'yes'
      redirect_to account_router_path
    end
  end
  
  def restart
    reset_session
    active_user.average_bps.each do |average_bp|
      average_bp.destroy
    end
    active_user.current_bps.each do |current_bp|
      current_bp.destroy
    end
    session[:restart_done] = 'yes'
    redirect_to account_router_path
  end
  
  def submit_readings
    
  end
  
  
  private
  
  def set_batch_average_bp_count
    @batch_average_bp_count = batch_average_bp_count
  end
  
  def set_first_average_bp
    @first_average_bp = active_user.average_bps.first
  end
  
  def is_restart_needed(date_comparator, ampm_comparator)
    if @first_average_bp.ampm == 'am'
      @ampm_adjustment = 0
    else
      @ampm_adjustment = 1 # if started readings in pm then allowed an additional collection
    end
    
    if ampm_comparator == 'am'
      @ampm_adjustment += 1 # if now am then there is an additional collection later in the day
    end
    
    if (12 - (((date_comparator - @first_average_bp.date).to_i) * 2) + @ampm_adjustment) < (8 - batch_average_bp_count) # 12 rather than 14 as first date evaluates as 0 when subtracted.
      true
    else
      false
    end
  end

end