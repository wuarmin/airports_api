require_relative './base_input_object'
require_relative './airport_filter_parameters'
require_relative './airport_order_definition'

module InputTypes
  class AirportSearchParameters < InputTypes::BaseInputObject
    description "Parameters to search airports"
    argument :filter, InputTypes::AirportFilterParameters, required: false, default_value: {}
    argument :order_definition, [InputTypes::AirportOrderDefinition], required: false, default_value: [{sortOrder: :asc, field: :id}]
  end
end
