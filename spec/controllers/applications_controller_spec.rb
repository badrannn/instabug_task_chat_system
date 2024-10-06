require "rails_helper"
require "sidekiq/testing"

RSpec.describe ApplicationsController, type: :request do
  let(:valid_attributes) { { name: Faker::App.name } }
  let(:invalid_attributes) { { name: "" } }
  let(:token) { SecureRandom.urlsafe_base64(nil, false) }

  before do
    Sidekiq::Queues.clear_all
    Application.delete_all
  end

  describe "POST" do
    context "with valid parameters" do
      it "creates a new application and returns the generated token" do
        post "/applications", params: { application: valid_attributes }
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include(:token.to_s)
      end

      it "enqueues a background job to process the application creation" do
        post "/applications", params: { application: valid_attributes }
        expect(Sidekiq::Queues["application_creator"].size).to eq(1)
      end
    end

    context "with invalid parameters" do
      it "does not create a new application" do
        post "/applications", params: { application: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it "does not enqueue a background job" do
        post "/applications", params: { application: invalid_attributes }
        expect(Sidekiq::Queues["application_creator"].size).to eq(0)
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
          post "/applications", params: { application: valid_attributes }
        }.to change(Application, :count).by(1)
      end
      it "does not create a new entity" do
        expect {
          post "/applications", params: { application: invalid_attributes }
        }.to change(Application, :count).by(0)
      end
    end
  end

  describe "GET" do
    context "when application exists" do
      let!(:application) { FactoryBot.create(:application) }
      it "returns the application" do
        get "/applications/#{application.token}"
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq(application.name)
      end
    end

    context "when application does not exist" do
      it "returns a not found response" do
        get "/applications/nonexistenttoken"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
  describe "PATCH" do
    context "when application exists" do
      let!(:application) { FactoryBot.create(:application) }
      let(:new_attributes) { { name: Faker::App.name } }

      it "updates the application" do
        patch "/applications/#{application.token}", params: { application: new_attributes }
        application.reload
        expect(application.name).to eq(new_attributes[:name])
        expect(response).to have_http_status(:ok)
      end
    end

    context "when application does not exist" do
      it "returns a not found response" do
        patch "/applications/nonexistenttoken", params: { application: { name: "New Name" } }
        expect(response).to have_http_status(:not_found)
      end
    end
    context "with invalid parameters" do
      let!(:application) { FactoryBot.create(:application) }
      it "does not update the application and returns errors" do
        patch "/applications/#{application.token}", params: { application: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
      end
    end
  end
end
