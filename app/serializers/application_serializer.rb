class ApplicationSerializer < ActiveModel::Serializer
  attributes :name, :token, :chats_count
  has_many :chats
end
