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
end
