require_relative './user_type'
require_relative './sign_in_return_type'
require_relative '../input_types/auth_credentials'
require_relative '../helpers/auth'

class Types::MutationType < GraphQL::Schema::Object
  include Helpers::Auth

  field :create_user, Types::UserType, null: false do
    argument :credentials, InputTypes::AuthCredentials, required: true
  end

  field :sign_in, Types::SignInReturnType, null: false do
    argument :credentials, InputTypes::AuthCredentials, required: true
  end

  def create_user(credentials)
    authorize

    result = Services::CreateUser.new.call(**credentials[:credentials])
    if (result.success?)
      result.value!
    else
      raise GraphQL::ExecutionError, result.failure.join(' ')
    end
  end

  def sign_in(credentials)
    result = Services::SignInUser.new.call(**credentials[:credentials])
    if (result.success?)
      result.value!
    else
      raise GraphQL::ExecutionError, result.failure.join(' ')
    end
  end
end
