require_relative '../graphql/schema'

module Controllers
  class GraphQL
    include Hanami::Action

    def call(params)
      query = params.get(:query)
      status 200, Schema.execute(query).to_json
    end
  end
end
