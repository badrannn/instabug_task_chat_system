require "json"

class Application < ApplicationRecord
  self.primary_key = :token
  has_many :chats, foreign_key: :application_token, primary_key: :token, dependent: :destroy

  validates :name, presence: true
end
