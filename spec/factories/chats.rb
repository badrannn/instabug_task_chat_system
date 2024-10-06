FactoryBot.define do
  factory :chat do
    application_token { SecureRandom.urlsafe_base64(nil, false) }
    number { Chat.count + 1 }
  end
end
