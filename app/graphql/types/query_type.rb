require_relative './airport_type'
require_relative '../input_types/airport_search_parameters'
require_relative './airport_connection_type'
require_relative '../helpers/auth'

module Types
  class QueryType < GraphQL::Schema::Object
    include Helpers::Auth

    description 'The query root of this schema'

    field :airport, Types::AirportType, null: true do
      description 'Find an airport by ID'
      argument :id, ID, required: true
    end


    field :search_airports, Types::AirportConnectionType, null: false, connection: true, max_page_size: ENV['GQL_MAX_PAGE_SIZE'].to_i do
      argument :parameters, InputTypes::AirportSearchParameters, required: false, default_value: {
        filter: {},
        orderDefinition: [{sortOrder: :asc, field: :id}]
      }
    end

    # resolvers

    def airport(id:)
      authorize
      Models::Airport.find(id: id)
    end

    def search_airports(search_airport_input)
      authorize
      result = Services::SearchAirports.new.call(**search_airport_input[:parameters])
      if (result.success?)
        result.value!
      else
        raise GraphQL::ExecutionError, result.failure.join(' ')
      end
    end

  end
end
