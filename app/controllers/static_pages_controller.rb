class StaticPagesController < ApplicationController
  
  def features
  end

  def about
  end

  def tac
  end
  
  def redirect
    redirect_to root_path
  end
  
  def send_to_landing_page
    redirect_to l_path('home-blood-pressure')
  end
  
end
