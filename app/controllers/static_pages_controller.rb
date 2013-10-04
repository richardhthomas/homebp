class StaticPagesController < ApplicationController
  def home
    @last_bp = active_user.average_bps.limit(1).order('id desc')
  end

  def about
  end

  def contact_us
  end

  def tac
  end
  
  def sign_in_msg
  end
  
  def landing_page
  end
  
  def how_to_monitor_bp
  end
  
  def choosing_a_monitor
  end
  
  def how_to_measure_bp
  end
  
  def when_to_measure_bp
  end
end
