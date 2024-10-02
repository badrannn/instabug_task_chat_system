class CreateApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :applications do |t|
      t.string :name
      t.string :token, null: false, unique: true, index: true
      t.integer :chats_count, default: 0, null: false

      t.timestamps
    end
  end
end
