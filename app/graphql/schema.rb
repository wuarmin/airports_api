require_relative 'types/query_type'

class Schema < GraphQL::Schema
  # use GraphQL::Execution::Interpreter
  use GraphQL::Pagination::Connections
  # use GraphQL::Analysis::AST

  query(Types::QueryType)
end
