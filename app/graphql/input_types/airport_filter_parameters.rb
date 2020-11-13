require_relative './base_input_object'
require_relative './geo_position'

module InputTypes
  class AirportFilterParameters < InputTypes::BaseInputObject
    description "Parameters to search airports"
    argument :geo_position, InputTypes::GeoPosition, required: false
    argument :country_code, String, required: false
  end
end
