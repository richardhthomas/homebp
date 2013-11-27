class AccountController < ApplicationController
  before_action :set_date_ampm
  before_action :batch_average_bp, only: [:home, :readings_due]
  before_action :set_batch_average_bp_count, only: [:home, :readings_due]
  before_action :set_last_average_bp, only: [:router, :set_bp_entry_datetime]
  
  def home
    @current_average_bp = active_user.average_bps.last
  end
  
  def router
    collect_bp_entry_datetime
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
        redirect_to account_set_bp_entry_datetime_path(@bp_entry_datetime)
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
    collect_bp_entry_datetime
    # first check if have started giving readings this session
    if session[:average_bp_given] != nil # if started giving readings already, or has skipped some time slots, then increment to next time slot
      if @bp_entry_datetime[:ampm] == "am"
        @bp_entry_datetime[:ampm] = "pm"
      else
        @bp_entry_datetime[:date] += 1
        @bp_entry_datetime[:ampm] = "am"
      end
    else # otherwise define timeslot based on last reading in the database
      if @last_average_bp.ampm == "am"
        @bp_entry_datetime[:date] = @last_average_bp.date
        @bp_entry_datetime[:ampm] = "pm"
      else
        @bp_entry_datetime[:date] = @last_average_bp.date + 1
        @bp_entry_datetime[:ampm] = "am"
      end
    end
    redirect_to account_readings_due_path(@bp_entry_datetime)
  end
  
  def readings_due
    collect_bp_entry_datetime
    set_old_bp_datetime
  end
  
  def is_bp_set_completable
    collect_bp_entry_datetime
    session[:average_bp_given] = 'skipped' # set :average_bp_given so that on returning to readings_due, the date and ampm are incremented rather than being defined from the last bp again
    @first_average_bp = active_user.average_bps.first
    if ((7-((session[:date_for_bp_entry] - @first_average_bp.date).to_i)) * 2) < (8 - batch_average_bp_count)
      redirect_to account_restart_path
    else
      redirect_to account_set_bp_entry_datetime_path(@bp_entry_datetime)
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

end