class CreateTrainStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :train_statuses, id: :string do |t|
      t.string :railway, null: false, default: ""
      t.string :operator, null: false, default: ""
      t.jsonb :status, null: false, default: {}
      t.timestamps
    end
  end
end
