class LandingPagesController < ApplicationController
  
  layout "landing_page"
  
  def show
    heading = params[:id].tr('-', ' ')
    @title = I18n.t heading, default: heading
  end
  
  def find_out_more
    heading = params[:title]
    @title = I18n.t heading, default: heading
  end
end