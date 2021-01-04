class AddRailwayToDevice < ActiveRecord::Migration[6.0]
  def change
    add_column :devices, :railways, :string, array: true, default: [], null: false
  end
end
