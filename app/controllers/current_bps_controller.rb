class CurrentBpsController < ApplicationController
  before_filter :set_cache_buster
  before_action :set_current_bp, only: [:show, :edit, :update, :destroy]
  before_action :set_current_bps, only: [:display_bp, :review]
  before_action :set_average_bp, only: [:new, :new2, :display_bp]

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
          format.html { redirect_to display_bp_current_bps_path, notice: 'Current bp was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { redirect_to new2_current_bps_path, notice: 'Current bp was successfully updated.' }
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
    if session[:temp_user_id]
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
          format.html { redirect_to current_bps_path }
        else
          format.html { render action: 'new' }
        end
      end
    else
      redirect_to review_current_bps_path
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
      @bp_set = active_user.current_bps
      @average_sysbp = @bp_set.average(:sysbp)
      @sys_position = 70 + ((170 - @average_sysbp)*3.5)
      @average_diabp = @bp_set.average(:diabp)
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def current_bp_params
      params.require(:current_bp).permit(:sysbp, :diabp)
    end
    
end
