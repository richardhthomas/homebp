class CreateTempUsers < ActiveRecord::Migration
  def change
    create_table :temp_users do |t|

      t.timestamps
    end
  end
end
