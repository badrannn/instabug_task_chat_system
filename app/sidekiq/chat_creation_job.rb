class ChatCreationJob
  include Sidekiq::Job
  queue_as :chat_creator

  def perform(opts = {})
    Rails.logger.info(opts)
    parsed_opts = JSON.parse(opts)
    chat = Chat.new(application_token: parsed_opts["token"], number: parsed_opts["number"])

    begin
      ActiveRecord::Base.transaction do
        chat.save!
        Rails.logger.info("chat #{chat.id} created successfully.")
      end
    rescue StandardError => e
      Rails.logger.error("An error occurred while creating chat: #{e.message}")
    end
  end
end
