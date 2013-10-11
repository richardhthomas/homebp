class AddGroupToDrugs < ActiveRecord::Migration
  def change
    add_column :drugs, :group, :text
  end
end
