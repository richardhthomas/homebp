class CreateDrugs < ActiveRecord::Migration
  def change
    create_table :drugs do |t|
      t.text :brand
      t.text :generic

      t.timestamps
    end
  end
end
