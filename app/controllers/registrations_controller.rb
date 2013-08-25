class RegistrationsController < Devise::RegistrationsController

  protected

  def after_sign_up_path_for(resource)
    signup_bp_migration_current_bps_path
  end
end 