class AccountController < ApplicationController
  before_action :set_date_ampm
  before_action :batch_average_bp, only: [:home, :readings_due]
  before_action :set_last_average_bp, only: [:router, :readings_due]
  
  def home
    @current_average_bp = active_user.average_bps.last
    if @current_average_bp.sysbp > 179 or @current_average_bp.diabp > 109
      @warning_message = "Your blood pressure readings were very high. You should see a healthcare professional within the next 24 hours. They will check that they are accurate readings. If they are accurate, you may need to start treatment immediately."
    elsif @current_average_bp.sysbp < 90 or @current_average_bp.diabp < 60
      @warning_message = "Your blood pressure readings were low. This is more common in young women. If you feel well then this is normal. If you are having dizziness, fainting episodes or feel nauseous you should make an appointment to see a healthcare professional."
    end
    
    if @average_sysbp > 129 or @average_diabp > 80
      @average_bp_message = "Your blood pressure readings so far show that you may have high blood pressure..."
    elsif @average_sysbp < 90 or @average_diabp < 60
      @average_bp_message = "Your blood pressure readings so far show that your blood pressure is quite low..."
    else
      @average_bp_message = "Your blood pressure readings so far show that you have normal blood pressure..."
    end
    
    if @current_average_bp.ampm == 'am'
      @when_next_reading = "this evening"
    else
      @when_next_reading = "tomorrow morning"
    end
    
    @batch_average_bp_count = batch_average_bp_count
  end
  
  def router
    if user_signed_in?
      #Check if any readings at all, if not ask to take reading now
      if batch_average_bp_count < 1
        redirect_to new_current_bps_path
    
      # check if has full set of bp readings
      elsif batch_average_bp_count >=8
        redirect_to #SUBMIT READINGS
    
      #check if they are too early for next reading
      elsif (session[:date] == @last_average_bp.date && session[:ampm] == @last_average_bp.ampm)
        redirect_to home_account_path #COME BACK AT TIME X FOR NEXT READING
    
      #so otherwise, readings are due
      else
        redirect_to readings_due_account_path
      end
      
    else
      if batch_average_bp_count < 1 # not signed in and no readings - go to landing page
        redirect_to blood_pressure_treatment_path
      
      else # not signed in but given a reading - go to home page
        redirect_to home_account_path
      end
    end 
  end
  
  def readings_due 
    # first check if have started giving readings this session by using the :reading_counter variable
    if session[:reading_counter] # if started giving readings already then increment to next time slot
      if session[:ampm_for_bp_entry] == "am"
        session[:ampm_for_bp_entry] = "pm"
      else
        session[:date_for_bp_entry] += 1
        session[:ampm_for_bp_entry] = "am"
      end
    else # otherwise define timeslot based on last reading in the database
      if @last_average_bp.ampm == "am"
        session[:date_for_bp_entry] = @last_average_bp.date
        session[:ampm_for_bp_entry] = "pm"
      else
        session[:date_for_bp_entry] = @last_average_bp.date + 1
        session[:ampm_for_bp_entry] = "am"
      end
    end
  end
  
  def is_bp_set_completable
    # check if has taken too long to collect readings
    session[:reading_counter] = 1 # set :reading_counter so that on returning to readings_due, the date and ampm are incremented rather than being defined from the last bp again
    @first_average_bp = active_user.average_bps.first
    if ((7-((session[:date_for_bp_entry] - @first_average_bp.date).to_i)) * 2) < (8 - batch_average_bp_count)
      redirect_to #NEED TO RESTART TAKING READINGS
    else
      redirect_to readings_due_account_path
    end
  end
  
  
  private
  
  def set_last_average_bp
    @last_average_bp = active_user.average_bps.last
  end

end