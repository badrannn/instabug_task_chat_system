class AddLockVersion < ActiveRecord::Migration[7.0]
  def change
    add_column :applications, :lock_version, :integer, default: 0, null: false
    add_column :chats, :lock_version, :integer, default: 0, null: false
  end
end
