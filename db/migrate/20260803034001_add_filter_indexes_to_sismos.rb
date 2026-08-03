class AddFilterIndexesToSismos < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :sismos, :mag, algorithm: :concurrently
    add_index :sismos, :magType, algorithm: :concurrently
    add_index :sismos, :created_at, algorithm: :concurrently
  end
end
