class ChatsController < ApplicationController
  def create
    if Application.exists?(token: params[:application_token])
      chats_count = Chat.where(application_token: params[:application_token]).count
      opts = { "token" => params[:application_token], "number" => chats_count + 1 }
      ChatCreationJob.perform_async(opts.to_json)
      render json: { message: "Chat is being created. Your chat number is #{chats_count + 1}" }, status: :created
    else
      render json: { message: "Application not found" }, status: :not_found
    end
  end

  def index
    chats = Chat.where(application_token: params[:application_token])
    if chats.any?
      render json: chats, status: :ok
    else
      render json: { message: "No chats found for this application." }, status: :not_found
    end
  end

  def show 
    chat = Chat.find_by(application_token: params[:application_token], number: params[:number])
    if chat.present?
      render json: chat, status: :ok
    else
      render json: { message: "Chat not found" }, status: :not_found
    end
  end
end
