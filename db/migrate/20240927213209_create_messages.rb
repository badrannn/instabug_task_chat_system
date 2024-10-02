class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.string :application_token, null: false  # Reference to the application token
      t.integer :chat_number, null: false        # Reference to the chat number
      t.integer :number, null: false              # Unique number for the message
      t.text :body
      t.timestamps
    end
    add_index :messages, [:application_token, :chat_number], name: "index_messages_on_application_token_and_chat_number"
    add_index :messages, [:application_token, :chat_number, :number], unique: true, name: "index_messages_on_application_token_and_chat_number_and_number"
  end
end
