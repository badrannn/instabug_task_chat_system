module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    mappings do
      indexes :body, type: "text"
    end

    def self.search(query)
      return [] if query.blank?
      params = {
        query: {
          match: {
            body: {
              query: query,
              fuzziness: "AUTO",
            },
          },
        },
      }
      self.__elasticsearch__.search(params).records.to_a
    end
  end
end
