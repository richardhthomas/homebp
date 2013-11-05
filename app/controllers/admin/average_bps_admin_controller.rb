class Admin::AverageBpsAdminController < ApplicationController
  before_action :set_average_bp, only: [:edit, :update, :destroy]

  def index
    @average_bps = AverageBp.all
  end

  def edit
  end
  
  def update
    respond_to do |format|
      if @average_bp.update(average_bp_params)
          format.html { redirect_to admin_average_bps_path }
          format.json { head :no_content }
      else
          format.html { render 'edit' }
          format.json { render json: @average_bp.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @average_bp.destroy
    respond_to do |format|
      format.html { redirect_to admin_average_bps_path }
      format.json { head :no_content }
    end
  end
  
  private
  def set_average_bp
    @average_bp = AverageBp.find(params[:id])
  end
  
  def average_bp_params
      params.require(:average_bp).permit(:sysbp, :diabp)
  end
  
end