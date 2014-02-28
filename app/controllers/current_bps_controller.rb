class CurrentBpsController < ApplicationController
  before_action :set_cache_buster
  before_action :authenticate_user!
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
          status = user_signed_in? ? 'signed in' : 'signed out'
          flash[:event] = 'BP given'
          flash[:event_properties] = 'signed in?,' + status
          format.html { redirect_to new_current_bp_path(@bp_entry_details) }
        end
      else
        #landing_page_setup
        format.html { render action: 'new' } #Rails.application.routes.recognize_path(request.referer)[:action] }
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
        #landing_page_setup
        format.html { render action: 'new' } #Rails.application.routes.recognize_path(request.referer)[:action] }
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
    flash[:alias] = current_user.email
    flash[:identify] = current_user.email
    flash[:people] = {}
    flash[:people][:email] = current_user.email
    flash[:people][:created] = Time.now.to_formatted_s(:db)
    flash[:event] = 'sign-up'
    
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
      redirect_to account_router_path, notice: 'Welcome to HomeBloodPressure.co.uk'
    end
  end

  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_current_bp
      @current_bp = CurrentBp.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def current_bp_params
      params.require(:current_bp).permit(:sysbp, :diabp)
    end
    
    def current_bp_params_datetime_only
      params.require(:current_bp).permit(:datetime, :reading_no, :bp_given)
    end
  
end
