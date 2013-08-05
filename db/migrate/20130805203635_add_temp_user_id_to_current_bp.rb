class AddTempUserIdToCurrentBp < ActiveRecord::Migration
  def change
    add_column :current_bps, :temp_user_id, :integer
  end
end
