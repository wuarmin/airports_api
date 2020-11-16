require_relative './base_input_object'
require_relative './airport_order_field'
require_relative './sort_order'

module InputTypes
  class AirportOrderDefinition < InputTypes::BaseInputObject
    description "Parameters to order airports"
    argument :field, Types::AirportOrderField, required: false
    argument :sort_order, Types::SortOrder, required: false, default_value: :asc
  end
end
