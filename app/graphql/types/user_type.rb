module Types
  class UserType < GraphQL::Schema::Object
    description "An api user"
    field :id, ID, null: false
    field :email, String, null: false
  end
end
