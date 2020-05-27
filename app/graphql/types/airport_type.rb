module Types
  class AirportType < GraphQL::Schema::Object
    description "An airport"
    field :id, ID, null: false
    field :iata_code, String, null: false
    field :name, String, null: false
  end
end
