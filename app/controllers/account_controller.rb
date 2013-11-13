class AccountController < ApplicationController
  before_action :set_average_bp, only: [:home]
  
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
  
end