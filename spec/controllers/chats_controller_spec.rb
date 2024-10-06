require "rails_helper"
require "sidekiq/testing"

RSpec.describe ChatsController, type: :request do
  let!(:application) { FactoryBot.create(:application) }

  before do
    Sidekiq::Queues.clear_all
    Chat.delete_all
  end

  describe "POST" do
    context "when application exists" do
      it "creates a new chat and returns the chat number" do
        post "/applications/#{application.token}/chats"
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Chat is being created. Your chat number is 1")
      end

      it "enqueues a background job to process the chat creation" do
        post "/applications/#{application.token}/chats"
        expect(Sidekiq::Queues["chat_creator"].size).to eq(1)
      end
    end

    context "when application does not exist" do
      it "returns a not found message" do
        post "/applications/invalidtoken/chats"
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Application not found")
      end
    end

    context "testing job execution" do
      before do
        Sidekiq::Testing.inline!  # Override behavior for this test only
      end
      after do
        Sidekiq::Testing.fake! # Reset to default behavior
      end
      it "creates a new application and returns the generated token" do
        expect {
          post "/applications/#{application.token}/chats"
        }.to change(Chat, :count).by(1)

        post "/applications/#{application.token}/chats"
        expect(Chat.last.number).to eq(2)
      end
      it "does not create a new entity" do
        expect {
          post "/applications/invalidtoken/chats"
        }.to change(Chat, :count).by(0)
      end
    end
  end

  describe "GET" do
    let!(:chat) { FactoryBot.create(:chat, application_token: application.token) }
    context "when chat exists" do
      it "returns the chat details" do
        get "/applications/#{application.token}/chats/#{chat.number}"
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["number"]).to eq(chat.number)
        expect(json_response["messages_count"]).to eq(0)
      end
    end
    context "when chat does not exist" do
      it "returns a not found response" do
        get "/applications/#{application.token}/chats/12"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
