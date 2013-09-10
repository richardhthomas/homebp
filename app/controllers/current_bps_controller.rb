class CurrentBpsController < ApplicationController
  before_filter :set_cache_buster
  before_action :set_current_bp, only: [:show, :edit, :update, :destroy]
  before_action :set_current_bps, only: [:display_bp, :review]
  before_action :set_average_bp, only: [:display_bp]
  before_action :set_average_bp_old, only: [:new, :new2]

  # GET /current_bps
  # GET /current_bps.json
  def index
    @current_bps = CurrentBp.all
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
      session[:date] = Date.today.to_s(:db)
      if DateTime.now.seconds_since_midnight < 43200
        session[:ampm] = "am"
      else
        session[:ampm] = "pm"
      end
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
          format.html { redirect_to display_bp_current_bps_path }
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
          format.html { redirect_to display_bp_current_bps_path }
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
  
  def display_bp
    @average_current_sysbp = @current_bps.average(:sysbp)
    @average_current_diabp = @current_bps.average(:diabp)
    
    if @average_current_sysbp > 179 or @average_current_diabp > 109
      @warning_message = "This last pair of blood pressure readings are very high. We recommend that you see a healthcare professional to discuss this within the next 24 hours."
    elsif @average_current_sysbp < 90 or @average_current_diabp < 60
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
    @current_bps = get_temp_user.current_bps.where(:date => session[:date], :ampm => session[:ampm])
    if @current_bps[1] #checks whether a second BP has been entered before migrating readings to new user account
      @saved = 0
      @temp_bp = get_temp_user.current_bps
      @temp_bp.each do |temp_bp|
        @current_bp = current_user.current_bps.build
        @current_bp.sysbp = temp_bp.sysbp
        @current_bp.diabp = temp_bp.diabp
        @current_bp.date = temp_bp.date
        @current_bp.ampm = temp_bp.ampm
        if @current_bp.save
          @saved += 1
        end
      end
      respond_to do |format|
        if @saved == 2
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
    
    # set_average_bp_old sets @average_sysbp and @average_diabp but only using values from prior to this session. set_average_bp uses all values.
    # The first is used for the new and new2 views when we don't want the display updating until a pair of new readings has been entered.
    
    def set_average_bp
      @bp_set = active_user.current_bps
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
    
    def set_average_bp_old
      @bp_set = active_user.current_bps.where('(date != ? AND ampm != ?)', session[:date], session[:ampm])
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
