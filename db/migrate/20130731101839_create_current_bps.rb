class CreateCurrentBps < ActiveRecord::Migration
  def change
    create_table :current_bps do |t|
      t.date :date
      t.string :ampm
      t.integer :sysbp
      t.integer :diabp

      t.timestamps
    end
  end
end
