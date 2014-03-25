class LandingPagesController < ApplicationController
  
  layout "landing_page"
  
  def show
    heading = params[:id].tr('-', ' ')
    @title = t("." + heading + ".title", default: heading)
    @subtitle = t("." + heading + ".subtitle", default: heading)
  end
  
  def find_out_more
    @title = params[:title]
    @subtitle = params[:subtitle]
  end
end