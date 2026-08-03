class AddExternalIdToSismos < ActiveRecord::Migration[7.1]
  def change
    add_column :sismos, :external_id, :string
  end
end
