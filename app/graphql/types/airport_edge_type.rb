require_relative './airport_type'

module Types
  class AirportEdgeType < GraphQL::Types::Relay::BaseEdge
    node_type(Types::AirportType)

    field :distance_to_geo_position, Integer, null: true

    def distance_to_geo_position
      object.node[:distance_to_geo_position]
    end
  end
end
