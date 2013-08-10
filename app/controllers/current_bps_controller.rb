class CurrentBpsController < ApplicationController
  before_action :set_current_bp, only: [:show, :edit, :update, :destroy]

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
    @current_bp = CurrentBp.new
    
    session[:date] = Date.today.to_s(:db)
    if DateTime.now.seconds_since_midnight < 43200
        session[:ampm] = "am"
    else
        session[:ampm] = "pm"
    end
    
    if session[:reading_counter].nil?
      session[:reading_counter] = 1
    else
      session[:reading_counter] += 1
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
        if session[:reading_counter] == 1
          format.html { redirect_to new_current_bp_path }
        else
        session[:reading_counter] = nil
        format.html { redirect_to display_bp_current_bps_path }
        format.json { render action: 'show', status: :created, location: @current_bp }
        end
        
      else
        format.html { render action: 'new' }
        format.json { render json: @current_bp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /current_bps/1
  # PATCH/PUT /current_bps/1.json
  def update
    respond_to do |format|
      if @current_bp.update(current_bp_params)
        format.html { redirect_to @current_bp, notice: 'Current bp was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @current_bp.errors, status: :unprocessable_entity }
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
    @current_bps = active_user.current_bps.where(:date => session[:date], :ampm => session[:ampm])
    session[:temp_user_id] = nil
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
end
