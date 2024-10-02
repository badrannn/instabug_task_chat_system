class MessagesController < ApplicationController
  def create
    if Chat.exists?(application_token: params[:application_token], number: params[:chat_number])
      if Message.new(message_params).valid?
        messages_count = Message.where(chat_number: params[:chat_number]).count
        render json: { message: "Message is being created. Your message number is #{messages_count + 1}" }, status: :created

        opts = { "token" => params[:application_token], "chat_number" => params[:chat_number],
                 "number" => messages_count + 1, "body" => message_params[:body] }
        MessageCreationJob.perform_async(opts.to_json)
      else
        render json: { message: "Message body is required" }, status: :bad_request
      end
    else
      render json: { message: "Chat not found" }, status: :not_found
    end
  end

  def show
    message = Message.find_by(application_token: params[:application_token], number: params[:number], chat_number: params[:chat_number])
    if message.present?
      render json: message, status: :ok
    else
      render json: { message: "message not found" }, status: :not_found
    end
  end

  def index
    messages = Message.where(chat_number: params[:chat_number])
    if messages.any?
      render json: messages, status: :ok
    else
      render json: { message: "No messages found for this chat." }, status: :not_found
    end
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
