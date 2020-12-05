require_relative './user_type'

module Types
  class SignInReturnType < GraphQL::Schema::Object
    description "The signIn return type"
    field :user, Types::UserType, null: false
    field :token, String, null: false
  end
end
