require_relative 'types/query_type'
require_relative 'types/mutation_type'

class Schema < GraphQL::Schema
  # use GraphQL::Execution::Interpreter
  use GraphQL::Pagination::Connections
  # use GraphQL::Analysis::AST

  query(Types::QueryType)
  mutation(Types::MutationType)
end
