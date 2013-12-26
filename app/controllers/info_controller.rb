class InfoController < ApplicationController
  before_action :set_cache_buster
  before_action :set_date_ampm
  before_action :collect_bp_entry_details, only: [:landing_page, :measuring_blood_pressure, :treating_blood_pressure, :what_is_blood_pressure]
  before_action :collect_bp, only: [:landing_page, :measuring_blood_pressure, :treating_blood_pressure, :what_is_blood_pressure]
  
  def landing_page
  end
  
  def measuring_blood_pressure
  end
  
  def treating_blood_pressure
  end
  
  def what_is_blood_pressure
  end
  
end