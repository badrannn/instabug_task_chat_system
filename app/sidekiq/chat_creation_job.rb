class ChatCreationJob
  include Sidekiq::Job
  queue_as :chat_creator

  def perform(opts = {})
    Rails.logger.info(opts)
    parsed_opts = JSON.parse(opts)
    chat = Chat.new(application_token: parsed_opts["token"], number: parsed_opts["number"])
    begin
      if chat.save
        Rails.logger.info("chat #{chat.id} created successfully.")
      else
        Rails.logger.error("Failed to create chat: #{chat.errors.full_messages.join(", ")}")
      end
    rescue StandardError => e
      Rails.logger.error("An error occurred while creating chat: #{e.message}")
    end
  end
end
