Elasticsearch::Model.client = Elasticsearch::Client.new(url: ENV["ELASTICSEARCH_URL"], log: true)

unless Rails.env.test? || (defined?(Sidekiq) && Sidekiq.server?)
  ActiveRecord::MigrationContext.new("db/migrate").migrate
  Rails.application.config.to_prepare do
    Message.import(force: true)
  end
end
