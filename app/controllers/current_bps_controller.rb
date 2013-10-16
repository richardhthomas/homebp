class CurrentBpsController < ApplicationController
  before_filter :set_cache_buster
  before_action :collect_first_bp, only: [:new, :landing_page, :how_to_measure_bp]
  before_action :set_current_bp, only: [:show, :edit, :update, :destroy]
  before_action :set_current_bps, only: [:create_average_bp, :display_bp, :review]
  before_action :set_average_bp, only: [:display_bp, :new, :new2]
  
  def router
    #see static pages controller for code that can return the last BP for a user
    @count = active_user.average_bps.count # this is just a count of the number of BPs associated with the user
    if @count > 0
      redirect_to display_bp_current_bps_path
    else
      session[:date] = Date.today #.to_s(:db) Removed this to allow date arithmetic (Was converting to string - not sure why I did this)
      if DateTime.now.seconds_since_midnight < 50400 #now 2pm is the start of pm!
        session[:ampm] = "am"
      else
        session[:ampm] = "pm"
      end
      redirect_to landing_page_current_bps_path
    end
  end
  
  # GET /current_bps
  # GET /current_bps.json
  def index
    @current_bps = CurrentBp.all
    @average_bps = AverageBp.all
  end

  # GET /current_bps/1
  # GET /current_bps/1.json
  def show
  end

  # GET /current_bps/new
  def new
  end

  def new2
    session[:reading_counter] = 2
    if second_bp
      @current_bp = second_bp
    else
      @current_bp = CurrentBp.new
    end
  end

  # GET /current_bps/1/edit
  def edit
  end

  # POST /current_bps
  # POST /current_bps.json
  def create
    @current_bp = active_user.current_bps.build(current_bp_params)
    @current_bp.date = session[:date]
    @current_bp.ampm = session[:ampm]

    respond_to do |format|
      if @current_bp.save
        if session[:reading_counter] == 2
          format.html { redirect_to create_average_bp_current_bps_path }
          format.json { render action: 'show', status: :created, location: @current_bp }
        else
          format.html { redirect_to new2_current_bps_path }
        end
      else
        if session[:reading_counter] == 1
          landing_page_setup
          format.html { render Rails.application.routes.recognize_path(request.referer)[:action] }
          format.json { render json: @current_bp.errors, status: :unprocessable_entity }
        else
          format.html { render action: 'new2' }
        end
      end
    end
  end

  # PATCH/PUT /current_bps/1
  # PATCH/PUT /current_bps/1.json
  def update
    respond_to do |format|
      if @current_bp.update(current_bp_params)
        if session[:reading_counter] == 2
          format.html { redirect_to create_average_bp_current_bps_path }
          format.json { head :no_content }
        else
          format.html { redirect_to new2_current_bps_path }
        end
      else
        if session[:reading_counter] == 1
          landing_page_setup
          format.html { render Rails.application.routes.recognize_path(request.referer)[:action] }
          format.json { render json: @current_bp.errors, status: :unprocessable_entity }
        else
          format.html { render action: 'new2' }
        end
      end
    end
  end

  # DELETE /current_bps/1
  # DELETE /current_bps/1.json
  def destroy
    @current_bp.destroy
    respond_to do |format|
      format.html { redirect_to current_bps_url }
      format.json { head :no_content }
    end
  end
  
  def create_average_bp
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
      @average_bp.save
    end
    
    redirect_to display_bp_current_bps_path
  end
  
  def display_bp
    @current_average_bp = active_user.average_bps.last
    if @current_average_bp.sysbp > 179 or @current_average_bp.diabp > 109
      @warning_message = "The readings you have just taken were very high. We recommend that you see a healthcare professional to discuss this within the next 24 hours."
    elsif @current_average_bp.sysbp < 90 or @current_average_bp.diabp < 60
      @warning_message = "The readings you have just taken were quite low. This can be normal, especially for young women, but if you feel unwell at all you should see a doctor as soon as possible."
    end
    
    if @average_sysbp > 129 or @average_diabp > 80
      @average_bp_message = "Your average readings so far show that you may have high blood pressure..."
    elsif @average_sysbp < 90 or @average_diabp < 60
      @average_bp_message = "Your average readings so far show that your blood pressure is quite low..."
    else
      @average_bp_message = "Your readings so far show that you have normal blood pressure..."
    end
    
    if @current_average_bp.ampm == 'am'
      @when_next_reading = "this evening"
    else
      @when_next_reading = "tomorrow morning"
    end
  end
  
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
          format.html { redirect_to display_bp_current_bps_path, notice: 'Welcome to HomeBloodPressure.co.uk' }
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
    # This was a test of date arithmetic
    #@record = CurrentBp.find(5)
    #@date = @record.date
    #@test = (session[:date] - @date).to_i
  end
  
  def choosing_a_monitor
  end
  
  def how_to_measure_bp
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_current_bp
      @current_bp = CurrentBp.find(params[:id])
    end
    
    def set_current_bps
      @current_bps = active_user.current_bps.where(:date => session[:date], :ampm => session[:ampm])
    end
    
    def first_bp
      set_current_bps
      @current_bps[0]
    end
    
    def second_bp
      set_current_bps
      @current_bps[1]
    end
    
    def set_average_bp
      @bp_set = active_user.average_bps
      @average_sysbp = @bp_set.average(:sysbp)
      @average_diabp = @bp_set.average(:diabp)
      if !@average_sysbp.nil?
        @sys_position = 70 + ((170 - @average_sysbp)*3.5)
        @dia_position = 70 + ((110 - @average_diabp)*4.66)
        if @sys_position < @dia_position
          @bp_position = @sys_position
        else
          @bp_position = @dia_position
        end
        if @bp_position < 70
          @bp_position = 70
        end
        if @bp_position > 280
          @bp_position = 280
        end
      end
    end
    
    def collect_first_bp
      session[:reading_counter] = 1
      if first_bp
        @current_bp = first_bp
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
    
end
