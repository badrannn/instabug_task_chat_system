require "json"

class ApplicationCreationJob
  include Sidekiq::Job
  queue_as :application_creator

  def perform(opts = {})
    Rails.logger.info(opts)
    parsed_opts = JSON.parse(opts)
    application = Application.new(name: parsed_opts["name"], token: parsed_opts["token"])

    begin
      if application.save
        Rails.logger.info("Application #{application.id} created successfully.")
      else
        Rails.logger.error("Failed to create application: #{application.errors.full_messages.join(", ")}")
      end
    rescue StandardError => e
      Rails.logger.error("An error occurred while creating application: #{e.message}")
    end
  end
end
