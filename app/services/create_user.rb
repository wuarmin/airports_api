module Services
  class CreateUser
    include Dry::Monads[:result]

    class UserValidator < Hanami::Validator
      schema do
        required(:email).filled(:string)
        required(:password).filled(:string)
      end

      rule(:email) do
        key.failure('is invalid') unless value =~ /[^\s]@[^\s]/
      end

      rule(:email) do
        key.failure('has already been taken') if Models::User.find_by_email(value)
      end
    end

    def call(params)
      validation_result = validate(params)
      if (validation_result.success?)
        Success(create_user(validation_result))
      else
        Failure(create_errors(validation_result.errors.to_h))
      end
    end

    private

    def validate(params)
      UserValidator.new.call(params)
    end

    def create_user(validation_result)
      Models::User.create({
        email: validation_result[:email],
        password_hash: bycrypt(validation_result[:password])
      })
    end

    def bycrypt(password)
      BCrypt::Password.create(password)
    end

    def create_errors(errors)
      flatten_hash(errors).map do |key, errors|
        "#{key} #{errors.join(', ')}"
      end
    end

    def flatten_hash(hash)
      hash.each_with_object({}) do |(k, v), h|
        if v.is_a? Hash
          flatten_hash(v).map do |h_k, h_v|
            h["#{k}.#{h_k}".to_sym] = h_v
          end
        else
          h[k] = v
        end
      end
    end

  end
end
