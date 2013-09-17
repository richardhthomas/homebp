class CreateAverageBps < ActiveRecord::Migration
  def change
    create_table :average_bps do |t|
      t.date :date
      t.string :ampm
      t.integer :sysbp
      t.integer :diabp
      t.integer :user_id
      t.integer :temp_user_id

      t.timestamps
    end
  end
end
