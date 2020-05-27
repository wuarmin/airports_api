class AirportsAPI < Hanami::API
  get "graphql", to: Controllers::GraphQL.new
end
