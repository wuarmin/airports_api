require_relative '../graphql/schema'

module Controllers
  class GraphQL
    include Hanami::Action

    def call(params)
      self.format = :json
      query = params.get(:query)
      context = { current_user: current_user }
      variables = ensure_hash(params.get(:variables))
      status 200, Schema.execute(query, variables: variables, context: context).to_json
    end

    private

    def current_user
      unless auth_token.nil?
        {
          id: auth_token.first['sub']
        }
      end
    end

    def auth_token
      JWT.decode(bearer_token, ENV['SECRET'], true, { algorithm: ENV['ALGORITHM'] })
    rescue JWT::DecodeError => e
      ap(e, indent: -2, index: false)
      nil
    end

    def bearer_token
      pattern = /^Bearer /
      header  = params.env['HTTP_AUTHORIZATION']
      header.gsub(pattern, '') if header && header.match(pattern)
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
