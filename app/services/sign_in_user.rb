module Services
  class SignInUser
    include Dry::Monads[:result, :do]

    class SignInValidator < Hanami::Validator
      schema do
        required(:email).filled(:string)
        required(:password).filled(:string)
      end

      rule(:email) do
        key.failure('is invalid') unless value =~ /[^\s]@[^\s]/
      end
    end

    def call(params)
      validation_result = yield validate(params)
      user = yield find_user(validation_result[:email])
      yield authenticate(user, validation_result[:password])
      create_token(user)
    end

    private

    def validate(params)
      validation_result = SignInValidator.new.call(params)
      if (validation_result.success?)
        Success(validation_result)
      else
        Failure(create_errors(validation_result.errors.to_h))
      end
    end

    def find_user(email)
      user = Models::User.find_by_email(email)
      unless user.nil?
        Success(user)
      else
        Failure(['no user found for given email'])
      end
    end

    def authenticate(user, password)
      if (BCrypt::Password.new(user.password_hash) == password)
        Success()
      else
        Failure(['authentication failed'])
      end
    end

    def create_token(user)
      exp = Time.now.to_i + 24 * 3600
      exp_payload = {
        iss: ENV['ISSUER'],
        exp: exp,
        sub: user.id.to_s
      }

      Success({
        token: JWT.encode(exp_payload, ENV['SECRET'], ENV['ALGORITHM']),
        user: user
      })
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
