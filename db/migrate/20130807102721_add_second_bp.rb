class AddSecondBp < ActiveRecord::Migration
  def change
    rename_column :current_bps, :sysbp, :sys1
    rename_column :current_bps, :diabp, :dia1
    add_column :current_bps, :sys2, :integer
    add_column :current_bps, :dia2, :integer
  end
end
