class Message < ApplicationRecord
  include Searchable
  validates :body, presence: true
end
