class CreateDevices < ActiveRecord::Migration[7.2]
  def change
    create_table :devices do |t|
      t.string :fcm_token, null: false, limit: 255
      t.string :platform, null: false, default: 'web'
      t.timestamps
    end

    add_index :devices, :fcm_token, unique: true
    add_check_constraint :devices, "platform = 'web'", name: 'devices_platform_is_web'
  end
end
