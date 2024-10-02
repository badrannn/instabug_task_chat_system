class ChatSerializer < ActiveModel::Serializer
  attributes :number, :messages_count
  has_many :messages
end
