class AccountController < ApplicationController
  before_action :set_average_bp, only: [:home, :readings_due]
  
  def home
    @current_average_bp = active_user.average_bps.last
    
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
    
    @set_average_bp_count = set_average_bp_count
  end
  
  def router
    @last_average_bp = active_user.average_bps.last
    @last_average_bp_date = @last_average_bp.date
    @last_average_bp_ampm = @last_average_bp.ampm
    
    #Check if any readings at all, if not, ask to take reading now
    #Is this necessary? It might be to avoid errors being thrown by their being no aveage_bp at all so getting nil classes...
    if set_average_bp_count < 1
      redirect_to new_current_bps_path #TAKE BP NOW
    
    # check if has full set of bp readings
    elsif set_average_bp_count >=8
      redirect_to #SUBMIT READINGS
    
    #check if they are too early for next reading
    elsif (session[:date] == @last_average_bp_date && session[:ampm] == @last_average_bp_ampm)
      redirect_to #COME BACK AT TIME X FOR NEXT READING - can be similar to 'home' view as it is now
    
    #so otherwise, readings are due
    else
      redirect_to #READINGS_DUE
    end
  end
  
  def readings_due 
    @last_average_bp = active_user.average_bps.last
    @last_average_bp_date = @last_average_bp.date
    @last_average_bp_ampm = @last_average_bp.ampm
    
    # First check if next reading is due now
    if (session[:date] == @last_average_bp_date && @last_average_bp_ampm == "am" && session[:ampm] == "pm") || (session[:date] == (@last_average_bp_date + 1) && @last_average_bp_ampm == "pm" && session[:ampm] == "am")
      @old_time_text = ""
    
    #otherwise there are missing readings so set up text to ask if they have any to enter from the next time slot
    else
      if session[:date] - @last_average_bp_date > 2
        if @last_average_bp_ampm == "am"
          @old_time_text = "the evening of" + @last_average_bp_date
          @old_bp_date = @last_average_bp_date
          @old_bp_ampm = "pm"
        else
          @old_time_text = "the morning of" + @last_average_bp_date + 1
          @old_bp_date = @last_average_bp_date + 1
          @old_bp_ampm = "am"
        end
      elsif session[:date] - @last_average_bp_date == 2
        if @last_average_bp_ampm == "am"
          @old_time_text = "the evening of" + @last_average_bp_date
          @old_bp_date = @last_average_bp_date
          @old_bp_ampm = "pm"
        else
          @old_time_text = "yesterday morning"
          @old_bp_date = @last_average_bp_date + 1
          @old_bp_ampm = "am"
        end
      else
        if @last_average_bp_ampm == "am"
          @old_time_text = "yesterday evening"
          @old_bp_date = @last_average_bp_date
          @old_bp_ampm = "pm"
        else
          @old_time_text = "this morning"
          @old_bp_date = @last_average_bp_date + 1
          @old_bp_ampm = "am"
        end
      end
    end
  end
  
  def is_bp_set_completable
    # check if has taken too long to collect readings
    @first_average_bp = active_user.average_bps.first
    if ((7-((session[:date] - @first_average_bp.date).to_i)) * 2) < (8 - set_average_bp_count)
      redirect_to #NEED TO RESTART TAKING READINGS
    else
      redirect_to new_current_bps_path
    end
  end

end