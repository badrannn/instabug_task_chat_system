class CountUpdaterJob
  include Sidekiq::Job
  queue_as :count_updater

  def perform()
    begin
      ActiveRecord::Base.transaction do
        Application.find_each do |application|
          application.update!(chats_count: application.chats.count)
        end

        Chat.find_each do |chat|
          chat.update(messages_count: chat.messages.count)
        end
      end
    end 
  end
end
