require "json"

class ApplicationCreationJob
  include Sidekiq::Job
  queue_as :application_creator

  def perform(opts = {})
    Rails.logger.info(opts)
    parsed_opts = JSON.parse(opts)
    application = Application.new(name: parsed_opts["name"], token: parsed_opts["token"])

    begin
      ActiveRecord::Base.transaction do
        application.save!
        Rails.logger.info("Application #{application.id} created successfully.")
      end
    rescue StandardError => e
      Rails.logger.error("An error occurred while creating application: #{e.message}")
    end
  end
end
