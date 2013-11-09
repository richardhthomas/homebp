class Admin::UserAdminController < Admin::AdminController
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users = User.all.order("id")
  end

  def edit
  end
  
  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
          format.html { redirect_to admin_users_path }
          format.json { head :no_content }
      else
          format.html { render 'edit' }
          format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_path }
      format.json { head :no_content }
    end
  end
  
  
  private
  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
      params.require(:user).permit(:email)
  end
  
end