require_relative './user_type'
require_relative '../input_types/auth_credentials'

class Types::MutationType < GraphQL::Schema::Object
  field :create_user, Types::UserType, null: false do
    argument :credentials, InputTypes::AuthCredentials, required: true
  end

  def create_user(credentials)
    result = Services::CreateUser.new.call(**credentials[:credentials])
    if (result.success?)
      result.value!
    else
      raise GraphQL::ExecutionError, result.failure.join(' ')
    end
  end
end
