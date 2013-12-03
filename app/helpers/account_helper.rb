module AccountHelper
  
  def old_bp_datetime_text
    @n = @bp_entry_details[:datetime].to_i
    if (session[:date] == session[:bp_entry_details][:date][@n]) && (session[:ampm] == session[:bp_entry_details][:ampm][@n])
      ""
    elsif (session[:date] - session[:bp_entry_details][:date][@n]).to_i > 1
      if session[:bp_entry_details][:ampm][@n] == "am"
        "the morning of " + session[:bp_entry_details][:date][@n].strftime("%d/%m/%y")
      else
        "the evening of " + session[:bp_entry_details][:date][@n].strftime("%d/%m/%y")
      end
    elsif (session[:date] - session[:bp_entry_details][:date][@n]).to_i == 1
      if session[:bp_entry_details][:ampm][@n] == "am"
        "yesterday morning"
      else
        "yesterday evening"
      end
    else
      "this morning"
    end
  end
  
  def bp_warning_message(current_average_bp)
    if current_average_bp.sysbp > 179 or current_average_bp.diabp > 109
      "Your last blood pressure readings were very high. You should see a healthcare professional within the next 24 hours. They will check that they are accurate readings. If they are accurate, you may need to start treatment immediately."
    elsif current_average_bp.sysbp < 90 or current_average_bp.diabp < 60
      "Your last blood pressure readings were low. This is more common in young women. If you feel well then this is normal. If you are having dizziness, fainting episodes or feel nauseated you should make an appointment to see a healthcare professional."
    end
  end
  
  def average_bp_message(average_sysbp, average_diabp)
    if average_sysbp > 129 or average_diabp > 80
      "Your blood pressure readings so far show that you may have high blood pressure..."
    elsif average_sysbp < 90 or average_diabp < 60
      "Your blood pressure readings so far show that your blood pressure is quite low..."
    else
      "Your blood pressure readings so far show that you have normal blood pressure..."
    end
  end
  
  def when_next_bp_reading(current_average_bp_ampm)
    if current_average_bp_ampm == 'am'
      "this evening"
    else
      "tomorrow morning"
    end
  end
  
  def time_left
    @days = (((8 - @batch_average_bp_count).to_f) / 2).ceil
    if session[:ampm] == 'am'
      @days -= 1
    end
    if @days > 1
      "over the next " + @days.to_s + " days"
    elsif @days == 1
      "tomorrow"
    else
      if session[:ampm] == 'am'
        "later today and tomorrow"
      else
        "later today"
      end
    end
  end
end