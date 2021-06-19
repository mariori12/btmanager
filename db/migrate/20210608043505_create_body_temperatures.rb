class CreateBodyTemperatures < ActiveRecord::Migration[6.0]
  def change
    create_table :body_temperatures do |t|
      t.date :measurement_date, null: false
      t.float :temperature, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :body_temperatures, [:measurement_date, :user_id], unique: true
  end
end
