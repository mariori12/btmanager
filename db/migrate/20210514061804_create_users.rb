class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest, null: false
      t.boolean :admin, default: false, null: false

      t.timestamps
      t.index :email, unique: true
    end
  end
end
