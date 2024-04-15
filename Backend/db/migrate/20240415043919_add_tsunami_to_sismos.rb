class AddTsunamiToSismos < ActiveRecord::Migration[7.1]
  def change
    add_column :sismos, :tsunami, :boolean
  end
end
