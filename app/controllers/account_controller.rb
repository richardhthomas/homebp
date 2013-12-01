class AccountController < ApplicationController
  before_action :set_date_ampm
  before_action :collect_bp_entry_details, only: [:router, :set_bp_entry_datetime, :readings_due, :is_bp_set_completable]
  before_action :format_date, only: [:set_bp_entry_datetime, :is_bp_set_completable]
  before_action :batch_average_bp, only: [:home, :readings_due]
  before_action :set_batch_average_bp_count, only: [:home, :readings_due]
  before_action :set_last_average_bp, only: [:router, :set_bp_entry_datetime]
  
  def home
    @current_average_bp = active_user.average_bps.last
  end
  
  def router
    if user_signed_in?
      #Check if any readings at all, if not ask to take reading now
      if batch_average_bp_count < 1
        redirect_to new_current_bp_path
    
      # check if has full set of bp readings
      elsif batch_average_bp_count >=8
        redirect_to account_submit_readings_path
    
      #check if they are too early for next reading
      elsif (session[:date] == @last_average_bp.date && session[:ampm] == @last_average_bp.ampm)
        redirect_to account_home_path
    
      #so otherwise, readings are due
      else
        redirect_to account_set_bp_entry_datetime_path(@bp_entry_details)
      end
      
    else
      if batch_average_bp_count < 1 # not signed in and no readings - go to landing page
        redirect_to blood_pressure_treatment_path
      
      else # not signed in but given a reading - go to home page
        redirect_to account_home_path
      end
    end 
  end
  
  def set_bp_entry_datetime
    # first check if have started giving readings this session
    if session[:average_bp_given] != nil # if started giving readings already, or has skipped some time slots, then increment to next time slot
      @bp_entry_details[:datetime].to_i += 1
    else # otherwise define the date and ampm slots required in session array and set to first time slot
      @session_bp_entry_details_date = @last_average_bp.date
      @session_bp_entry_details_ampm = @last_average_bp.ampm
      @time_slots_count = ((session[:date] - @last_average_bp.date).to_i) * 2
      if @last_average_bp.ampm == "am" # add another bp for collection if still need pm reading from date of @last_average_bp
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
        session[:bp_entry_details][n][:date] = @session_bp_entry_details_date
        session[:bp_entry_details][n][:ampm] = @session_bp_entry_details_ampm
      end
      
      @bp_entry_details[:datetime] = 1
    end
    redirect_to account_readings_due_path(@bp_entry_details)
  end
  
  def readings_due
    set_old_bp_datetime
  end
  
  def is_bp_set_completable
    session[:average_bp_given] = 'skipped' # set :average_bp_given so that on returning to readings_due, the date and ampm are incremented rather than being defined from the last bp again
    @first_average_bp = active_user.average_bps.first
    @n = @bp_entry_details[:datetime].to_i
    if ((7-((session[:bp_entry_details][@n][:date] - @first_average_bp.date).to_i)) * 2) < (8 - batch_average_bp_count)
      redirect_to account_restart_path
    else
      redirect_to account_set_bp_entry_datetime_path(@bp_entry_details)
    end
  end
  
  def restart
    #session[:reading_counter] = nil
    #session[:date] = nil
    #session[:ampm] = nil
    #active_user.average_bps.each do |average_bp|
    #  average_bp.destroy
    #end
    #active_user.current_bps.each do |current_bp|
    #  current_bp.destroy
    #end
  end
  
  def submit_readings
    
  end
  
  
  private
  
  def set_last_average_bp
    @last_average_bp = active_user.average_bps.last
  end
  
  def set_batch_average_bp_count
    @batch_average_bp_count = batch_average_bp_count
  end
  
  def format_date # returns date from string (in GET request) back to date
    @bp_entry_details[:date] = Date.strptime(@bp_entry_details[:date], "%Y-%m-%d")
  end

end