class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.string :application_token, null: false, index: true
      t.integer :number, null: false
      t.integer :messages_count, default: 0

      t.timestamps
    end
    add_index :chats, [:application_token, :number], unique: true, name: "index_chats_on_application_token_and_number"
    add_foreign_key :chats, :applications, column: :application_token, primary_key: :token
  end
end
