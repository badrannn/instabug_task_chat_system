FactoryBot.define do
  factory :application do
    name { Faker::App.name }
    token { SecureRandom.urlsafe_base64(nil, false) }
  end
end
