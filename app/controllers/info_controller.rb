class InfoController < ApplicationController
  before_action :set_cache_buster
  before_action :authenticate_user!
  before_action :set_date_ampm
  before_action :collect_bp_entry_details
  before_action :collect_bp
  
  def show
    @batch_average_bp_count = batch_average_bp_count
    page = "info/" + params[:id]
    render page
  end
  
end