require_relative './base_input_object'

module InputTypes
  class AuthCredentials < InputTypes::BaseInputObject
    description "Parameters to login"
    argument :email, String, required: true
    argument :password, String, required: true
  end
end
