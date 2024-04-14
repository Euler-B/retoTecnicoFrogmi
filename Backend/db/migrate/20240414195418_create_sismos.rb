class CreateSismos < ActiveRecord::Migration[7.1]
  def change
    create_table :sismos do |t|
      t.string :title
      t.string :url
      t.string :place
      t.string :magType
      t.float :mag
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
