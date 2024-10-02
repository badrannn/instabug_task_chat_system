Elasticsearch::Model.client = Elasticsearch::Client.new(url: ENV["ELASTICSEARCH_URL"], log: true)

unless defined?(Sidekiq) && Sidekiq.server?
  Rails.application.config.to_prepare do
    Message.import(force: true)
  end
end
