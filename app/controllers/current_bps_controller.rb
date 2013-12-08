class CurrentBpsController < ApplicationController
  before_action :set_cache_buster
  before_action :set_date_ampm
  before_action :collect_bp_entry_details, only: [:new, :landing_page, :create_average_bp]
  before_action :collect_bp, only: [:new, :landing_page]
  before_action :set_current_bp, only: [:update]
  before_action :batch_average_bp, only: [:new]

  # GET /current_bps/new
  def new
  end

  # POST /current_bps
  # POST /current_bps.json
  def create
    @bp_entry_details = current_bp_params_datetime_only
    @n = @bp_entry_details[:datetime].to_i
    
    @current_bp = active_user.current_bps.build(current_bp_params)
    @current_bp.date = session[:bp_entry_details][:date][@n]
    @current_bp.ampm = session[:bp_entry_details][:ampm][@n]

    respond_to do |format|
      if @current_bp.save
        if @bp_entry_details[:reading_no] == '2'
          format.html { redirect_to create_average_bp_current_bps_path(@bp_entry_details) }
        else
          @bp_entry_details[:reading_no] = '2'
          format.html { redirect_to new_current_bp_path(@bp_entry_details) }
        end
      else
        landing_page_setup
        format.html { render Rails.application.routes.recognize_path(request.referer)[:action] }
      end
    end
  end

  # PATCH/PUT /current_bps/1
  # PATCH/PUT /current_bps/1.json
  def update
    @bp_entry_details = current_bp_params_datetime_only
    
    respond_to do |format|
      if @current_bp.update(current_bp_params)
        if @bp_entry_details[:reading_no] == '2'
          format.html { redirect_to create_average_bp_current_bps_path(@bp_entry_details) }
        else
          @bp_entry_details[:reading_no] = '2'
          format.html { redirect_to new_current_bp_path(@bp_entry_details) }
        end
      else
        landing_page_setup
        format.html { render Rails.application.routes.recognize_path(request.referer)[:action] }
      end
    end
  end
  
  def create_average_bp
    set_current_bps
    
    @average_current_sysbp = @current_bps.average(:sysbp)
    @average_current_diabp = @current_bps.average(:diabp)
    
    @current_average_bp = active_user.average_bps.where(:date => @current_bps[0].date, :ampm => @current_bps[0].ampm).take #holds current average bp if one has already been created
    
    if !@current_average_bp.nil? # detects if already have an average bp, so can be overwritten in the case that user has gone back and altered values
      @current_average_bp.sysbp = @average_current_sysbp
      @current_average_bp.diabp = @average_current_diabp
      @current_average_bp.save
    else # create average bp
      @average_bp = active_user.average_bps.build
      @average_bp.sysbp = @average_current_sysbp
      @average_bp.diabp = @average_current_diabp
      @average_bp.date = @current_bps[0].date
      @average_bp.ampm = @current_bps[0].ampm
      if @average_bp.save
        @bp_entry_details[:bp_given] = 'yes' # this is used to determine text (GET / URL used so back action in browser is appropriate)
        session[:average_bp_given] = 'yes' # this is used to determine whether to run set_bp_entry_datetime or not (Session used so is pervasive)
      end
    end
    @bp_entry_details[:datetime] = @bp_entry_details[:datetime].to_i + 1
    @bp_entry_details[:reading_no] = '1'
    redirect_to account_router_path(@bp_entry_details)
  end 

  def signup_bp_migration
    @current_average_bp = get_temp_user.average_bps.where(:date => session[:date], :ampm => session[:ampm]).take
    if !@current_average_bp.nil? #checks whether an average BP has been created before migrating readings to new user account
      @average_bp = current_user.average_bps.build
      @average_bp.sysbp = @current_average_bp.sysbp
      @average_bp.diabp = @current_average_bp.diabp
      @average_bp.date = @current_average_bp.date
      @average_bp.ampm = @current_average_bp.ampm
      respond_to do |format|
        if @average_bp.save
          Notifier.sign_up(current_user, @average_bp.ampm).deliver #send sign_up email
          format.html { redirect_to account_home_path, notice: 'Welcome to HomeBloodPressure.co.uk' }
        else
          Notifier.sign_up(current_user, nil).deliver #send sign_up email
          format.html { render action: 'new' }
        end
      end
    else
      Notifier.sign_up(current_user, nil).deliver #send sign_up email
      redirect_to new_current_bp_path, notice: 'Welcome to HomeBloodPressure.co.uk'
    end
  end
  
  def landing_page
    landing_page_setup
  end
    
  def how_to_measure_bp
  end

  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_current_bp
      @current_bp = CurrentBp.find(params[:id])
    end
    
    def set_current_bps
      @n = @bp_entry_details[:datetime].to_i
      @current_bps = active_user.current_bps.where(:date => session[:bp_entry_details][:date][@n], :ampm => session[:bp_entry_details][:ampm][@n]).order("id")
    end
    
    def check_current_bp
      set_current_bps
      @key = @bp_entry_details[:reading_no].to_i - 1
      @current_bps[@key]
    end
    
    def collect_bp
      if check_current_bp
        @current_bp = check_current_bp
      else
        @current_bp = CurrentBp.new
      end
    end
    
    def landing_page_setup
      @drugs = Drug.all
      @medications = Hash.new { |hash, key| hash[key] = Hash.new }
      @drugs.each do |drug|
        if @medications[drug.group][drug.generic].nil?
          @medications[drug.group][drug.generic] = drug.brand
        else
          @medications[drug.group][drug.generic] += ", " + drug.brand
        end
      end
      @groups = @medications.keys
      @medication_explanation = Hash.new
      @medication_explanation["Calcium channel blockers"] = "If you’re of African or Caribbean origin, or any ethnicity and over 55 years old, then calcium channel blockers will be the first choice medication for you. If you are using them at higher doses then sometimes they can cause swelling around the ankles. If you reduce the dose then this usually gets better."
      @medication_explanation["ACE inhibitors"] = "If you are under 55 and not from an African or Caribbean background then these are likely to be the first choice medication for you. The most common side effect that you may get is a dry cough. Many people are able to tolerate this side effect, as the alternative medications can be less effective. If you are started on these medications you need to have blood tests to monitor your kidney function. Although these drugs usually protect the kidneys in people with high blood pressure, on rare occasions they can make them worse. Sometimes when you first start taking them, these medications can make you feel dizzy, but this usually gets better after you’ve been taking them for a couple of days."
      @medication_explanation["Angiotensin II receptor antagonists"] = "You will generally only be started on these medications if you cannot tolerate the dry cough from being on an ACE inhibitor. Although they have less side effects, there is not as much evidence as to their effectiveness as there is for ACE inhibitors. Like their close relations ACE inhibitors, sometimes when you first start taking them, these medications can make you feel dizzy, but this usually gets better after you’ve been taking them for a couple of days."
      @medication_explanation["Diuretics"] = "You may know diuretics as 'water tablets'. Unsurprisingly their common side effects include making you pass urine more often. These days they are most commonly used as a second line or additional treatment for blood pressure. If you are taking diuretics then your kidney function should be monitored."
      @medication_explanation["Beta-blockers"] = "These days beta-blockers are only used to add to other medications if they haven’t brought your blood pressure down. The most common side effect is that they may make you feel drowsy."
      @medication_explanation["Alpha-blockers"] = "These also are reserved as third or fourth line drugs to be used if your blood pressure is not adequately controlled with one or two other medications. Their main side effect is that when  you first start taking them they can cause dizziness. This usually gets better when you’ve been taking them for a few days."  
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def current_bp_params
      params.require(:current_bp).permit(:sysbp, :diabp)
    end
    
    def current_bp_params_datetime_only
      params.require(:current_bp).permit(:datetime, :reading_no, :bp_given)
    end
    
    
    ## Below are actions that may be useful occasionally in development, or are just not currently being used 
  def review
  end
  
  def update_bp
    @current_bps = CurrentBp.update(params[:current_bps].keys, params[:current_bps].values)
    @errors = @current_bps.reject { |p| p.errors.empty?}
    if @errors.empty?
      redirect_to display_bp_current_bps_path
    else
      render action: 'review'
    end
  end
  
  def choosing_a_monitor
  end
  
end
