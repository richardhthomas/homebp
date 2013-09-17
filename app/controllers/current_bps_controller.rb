class CurrentBpsController < ApplicationController
  before_filter :set_cache_buster
  before_action :set_current_bp, only: [:show, :edit, :update, :destroy]
  before_action :set_current_bps, only: [:create_average_bp, :display_bp, :review]
  before_action :set_average_bp, only: [:display_bp, :new, :new2]
  
  def router
    session[:date] = Date.today.to_s(:db)
    if DateTime.now.seconds_since_midnight < 43200
      session[:ampm] = "am"
    else
      session[:ampm] = "pm"
    end
    #@last_bp = active_user.current_bps.limit(1).order('id desc') This may work, but was returning an object which wasn't nil even when the active_user had no bps
    @count = active_user.average_bps.count # so for now this is just a count of the number of BPs associated with the user
    if @count > 0 #or last_bp is not from previous 12 hour slot
      redirect_to static_pages_home_path #to be replaced by code to determine if user is too early or too late
    else
      redirect_to new_current_bp_path
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
    session[:reading_counter] = 1
    if first_bp
      @current_bp = first_bp
    else
      @current_bp = CurrentBp.new
    end
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
          format.html { render action: 'new' }
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
          format.html { render action: 'new' }
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
      @warning_message = "This last pair of blood pressure readings are very high. We recommend that you see a healthcare professional to discuss this within the next 24 hours."
    elsif @current_average_bp.sysbp < 90 or @current_average_bp.diabp < 60
      @warning_message = "This last pair of blood pressure readings are quite low. This can be normal, especially for young women, but if you feel unwell at all you should see a doctor as soon as possible."
    end
    
    if @average_sysbp > 129 or @average_diabp > 80
      @message = "Your readings so far show that you may have high blood pressure..."
    else
      @message = "Your readings so far show that you have normal blood pressure..."
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
          format.html { redirect_to display_bp_current_bps_path, notice: 'Welcome to HomeBloodPressure.co.uk' }
        else
          format.html { render action: 'new' }
        end
      end
    else
      redirect_to new_current_bp_path, notice: 'Welcome to HomeBloodPressure.co.uk'
    end
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def current_bp_params
      params.require(:current_bp).permit(:sysbp, :diabp)
    end
    
end
