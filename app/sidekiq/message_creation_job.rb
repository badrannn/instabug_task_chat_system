class MessageCreationJob
  include Sidekiq::Job
  queue_as :message_creator

  def perform(opts)
    Rails.logger.info(opts)
    parsed_opts = JSON.parse(opts)
    message = Message.new(application_token: parsed_opts["token"], number: parsed_opts["number"], body: parsed_opts["body"], chat_number: parsed_opts["chat_number"])
    begin
      ActiveRecord::Base.transaction do
        message.save!
        Rails.logger.info("message #{message.id} created successfully.")
      end
    rescue StandardError => e
      Rails.logger.error("An error occurred while creating message: #{e.message}")
    end
  end
end
