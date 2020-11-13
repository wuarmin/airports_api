require_relative './base_enum'

class Types::AirportOrderField < Types::BaseEnum
  value "DISTANCE_TO_GEO_POSITION", value: :distance_to_geo_position
  value "NAME", value: :name
  value "ID", value: :id
end
