class ReturnToSingleBpPerRow < ActiveRecord::Migration
  def change
    remove_column :current_bps, :sys2
    remove_column :current_bps, :dia2
    rename_column :current_bps, :sys1, :sysbp
    rename_column :current_bps, :dia1, :diabp
  end
end
