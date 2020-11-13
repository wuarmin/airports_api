FactoryBot.define do
  factory :airport, class: 'Models::Airport' do
    iata_code { Faker::Alphanumeric.alpha(number: 3).upcase }
    icao_code { Faker::Alphanumeric.alpha(number: 4).upcase }
    name { "#{Faker::Address.city} Airport" }
    asciiname { "#{Faker::Address.city} Airport" }
    coordinates { "(#{Faker::Address.latitude}, #{Faker::Address.longitude})" }
    country_code { Faker::Address.country_code }
    country_name { Faker::Address.country }
    continent_name { Faker::Address.time_zone }
  end
end
