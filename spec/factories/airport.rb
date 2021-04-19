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
    adm1_code { nil }
    adm1_name { nil }
    adm1_name_ascii { nil }
    adm2_code { nil }
    adm2_name { nil }
    adm2_name_ascii { nil }
    adm3_code { nil }
    adm4_code { nil }
    population { nil }
    elevation { nil }
    gtopo30 { nil }
    timezone { nil }
    gmt_offset { nil }
    dst_offset { nil }
    raw_offset { nil }
  end
end
