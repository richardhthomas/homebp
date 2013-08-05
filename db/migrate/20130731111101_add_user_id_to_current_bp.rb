class AddUserIdToCurrentBp < ActiveRecord::Migration
  def change
    add_column :current_bps, :user_id, :integer
  end
end
