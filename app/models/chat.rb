class Chat < ApplicationRecord
  belongs_to :application, foreign_key: :application_token, primary_key: :token
  has_many :messages, dependent: :destroy, foreign_key: :chat_number, primary_key: :number
end
