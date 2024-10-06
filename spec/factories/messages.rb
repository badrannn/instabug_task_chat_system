FactoryBot.define do
  factory :message do
    application_token { SecureRandom.urlsafe_base64(nil, false) }
    chat_number { 1 }
    number { Message.where(chat_number: chat_number, application_token: application_token).count + 1 }
    body { Faker::Quote.famous_last_words }
  end
end
