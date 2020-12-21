module Helpers
  module Auth

    def authorize
      if context[:current_user].nil?
        raise GraphQL::ExecutionError.new("401 Unauthorized", extensions: { "code" => "UNAUTHORIZED" })
      end
    end

  end
end
