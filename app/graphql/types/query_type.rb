require_relative 'airport_type'

module Types
  class QueryType < GraphQL::Schema::Object
    description 'The query root of this schema'
    field :airport, Types::AirportType, null: true do
      description 'Find an airport by ID'
      argument :id, ID, required: true
    end

    def airport(id:)
      Models::Airport.find(id: id)
    end
  end
end
