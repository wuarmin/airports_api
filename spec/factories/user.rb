FactoryBot.define do
  factory :user, class: 'Models::User' do
    email { Faker::Internet.email }
    password_hash { BCrypt::Password.create("my password") }
  end
end
