class StaticPagesController < ApplicationController
  def home
    #@last_bp = active_user.average_bps.limit(1).order('id desc')
  end

  def about
  end

  def tac
  end
  
  def redirect
    redirect_to root_path
  end
  
end
