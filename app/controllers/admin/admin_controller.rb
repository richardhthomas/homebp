class Admin::AdminController < ApplicationController

  layout "application"
  before_filter :admin_required
  
  def menu
  end
  
end