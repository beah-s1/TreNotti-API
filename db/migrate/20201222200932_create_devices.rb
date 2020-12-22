class CreateDevices < ActiveRecord::Migration[6.0]
  def change
    create_table :devices, id: :string do |t|
      t.string :device_type, null: false, default: ""
      t.string :notification_token, null: false, default: ""
      t.string :hashed_token, null: false, default: ""
      t.timestamps
    end
  end
end
