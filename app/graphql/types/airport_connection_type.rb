require_relative './airport_edge_type'

module Types
  class AirportConnectionType < GraphQL::Types::Relay::BaseConnection
    edge_type(Types::AirportEdgeType)

    field :total_count, Integer, null: false

    def total_count
      object.items.count
    end
  end
end
