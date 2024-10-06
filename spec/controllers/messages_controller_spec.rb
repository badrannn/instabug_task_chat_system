require "rails_helper"
require "sidekiq/testing"

RSpec.describe MessagesController, type: :request do
  let!(:application) { FactoryBot.create(:application) }
  let!(:chat) { FactoryBot.create(:chat, application_token: application.token) }
  let(:valid_attributes) { { body: Faker::Quote.famous_last_words } }
  let(:invalid_attributes) { { body: "" } }

  before do
    Sidekiq::Queues.clear_all
    Message.delete_all
  end
  describe "POST" do
    context "when chat exists" do
      it "creates a new message and returns the message number" do
        post "/applications/#{application.token}/chats/#{chat.number}/messages", params: { message: valid_attributes }
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Message is being created. Your message number is 1")
      end
    end
    context "when chat does not exist" do
      it "returns a not found message" do
        post "/applications/#{application.token}/chats/invalidnumber/messages", params: { message: valid_attributes }
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Chat not found")
      end
    end
    context "with invalid parameters" do
      it "does not create a new message" do
        post "/applications/#{application.token}/chats/#{chat.number}/messages", params: { message: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    context "testing job execution" do
      before do
        Sidekiq::Testing.inline!
      end
      after do
        Sidekiq::Testing.fake!
      end
      it "creates a new message and returns the generated number" do
        expect {
          post "/applications/#{application.token}/chats/#{chat.number}/messages", params: { message: valid_attributes }
        }.to change(Message, :count).by(1)
      end
      it "does not create a new entity" do
        expect {
          post "/applications/#{application.token}/chats/#{chat.number}/messages", params: { message: invalid_attributes }
        }.to change(Message, :count).by(0)
      end
    end
    context "testing enqueued job" do
      it "enqueues a background job to process the message creation" do
        post "/applications/#{application.token}/chats/#{chat.number}/messages", params: { message: valid_attributes }
        expect(Sidekiq::Queues["message_creator"].size).to eq(1)
      end
    end
  end
  describe "GET" do
    let!(:message) { FactoryBot.create(:message, chat_number: chat.number, application_token: application.token) }
    context "when message exists" do
      it "returns the message details" do
        get "/applications/#{application.token}/chats/#{chat.number}/messages/#{message.number}"
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["body"]).to eq(message.body)
      end
    end
    context "when message does not exist" do
      it "returns a not found message" do
        get "/applications/#{application.token}/chats/#{chat.number}/messages/invalidnumber"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
