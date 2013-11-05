class Admin::CurrentBpsAdminController < ApplicationController
  before_action :set_current_bp, only: [:edit, :update, :destroy]

  def index
    @current_bps = CurrentBp.all
  end

  def edit
  end
  
  def update
    respond_to do |format|
      if @current_bp.update(current_bp_params)
          format.html { redirect_to admin_current_bps_path }
          format.json { head :no_content }
      else
          format.html { render 'edit' }
          format.json { render json: @current_bp.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @current_bp.destroy
    respond_to do |format|
      format.html { redirect_to admin_current_bps_path }
      format.json { head :no_content }
    end
  end
  
  private
  def set_current_bp
    @current_bp = CurrentBp.find(params[:id])
  end
  
  def current_bp_params
      params.require(:current_bp).permit(:sysbp, :diabp)
  end
  
end