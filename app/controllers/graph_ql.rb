require_relative '../graphql/schema'

module Controllers
  class GraphQL
    include Hanami::Action

    def call(params)
      self.format = :json
      query = params.get(:query)
      variables = ensure_hash(params.get(:variables))
      status 200, Schema.execute(query, variables: variables).to_json
    end

  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if !Hanami::Utils::Blank.blank?(ambiguous_param)
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end

  end
end
