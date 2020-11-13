require "hanami/validations"

RSpec.describe Services::SearchAirports do

  before(:all) do
    AppSpecHelper.create_airports
  end

  after(:all) do
    AppSpecHelper.delete_airports
  end

  describe '#call' do
    let(:params) do
      {
        filter: {
          geo_position: geo_position,
          country_code: country_code
        },
        order_definition: order_definition
      }
    end
    let(:geo_position) { nil }
    let(:radius) { nil }
    let(:country_code) { nil }
    let(:order_definition) { [{ field: :distance_to_geo_position, sort_order: :asc }] }

    context 'when params are valid' do
      context 'when geo_position is set' do
        let(:geo_position) { { latitude: 46.904732, longitude: 15.702838, radius: radius } }

        describe 'filtering' do
          context 'and radius is set' do
            let(:radius) { 6000*1000 }

            it 'should return airports with distances set' do
              airports = subject.call(**params).value!.all

              expect(airports.map do |airport|
                [airport[:name], airport[:distance_to_geo_position]]
              end).to eq([
                ["Vienna International Airport", 149979],
                ["Salzburg Airport", 226275]
              ])
            end
          end

          context 'when radius is not set' do
            let(:radius) { nil }

            it 'should return airports without distances set' do
              airports = subject.call(**params).value!.all

              expect(airports.map do |airport|
                [airport[:name], airport[:distance_to_geo_position]]
              end).to eq([
                ["Vienna International Airport", 149979],
                ["Salzburg Airport", 226275],
                ["Logan International Airport", 6523895],
                ["John F. Kennedy International Airport", 6823481],
              ])
            end
          end
        end

        describe 'order' do
          context 'when order definition is: order by distance_to_geo_position desc' do
            let(:order_definition) { [{ field: :distance_to_geo_position, sort_order: :desc }] }

            it 'should return correctly ordered airports' do
              airports = subject.call(**params).value!.all

              expect(airports.map do |airport|
                [airport[:name], airport[:distance_to_geo_position]]
              end).to eq([
                ["John F. Kennedy International Airport", 6823481],
                ["Logan International Airport", 6523895],
                ["Salzburg Airport", 226275],
                ["Vienna International Airport", 149979],
              ])
            end
          end
        end
      end

      context 'when country_code is set' do
        let(:country_code) { 'At' }
        let(:order_definition) { [{ field: :id, sort_order: :asc }] }

        it 'should return filtered airports' do
          airports = subject.call(**params).value!.all

          expect(airports.map { |airport| [airport[:name], airport[:country_code]] }).to eq([
            ["Salzburg Airport", "AT"],
            ["Vienna International Airport", "AT"]
          ])
        end
      end
    end

    context 'when params are invalid' do
      let(:geo_position) { { latitude: nil, longitude: '54564', radius: 'radius' } }
      let(:country_code) { 78 }

      it 'should fail with errors' do
        result = subject.call(**params)

        expect(result.failure?).to be(true)
        expect(result.failure).to eq([
          "filter.geo_position.latitude must be a float",
          "filter.geo_position.longitude must be a float",
          "filter.geo_position.radius must be an integer",
          "filter.country_code must be a string"
        ])
      end
    end

    context 'when geo_position is not set, but order definition contains order by distance_to_geo_position' do
      let(:geo_position) { nil }
      let(:country_code) { 'us' }
      let(:order_definition) { [{ field: :distance_to_geo_position, sort_order: :desc }] }

      it 'should fail with an error' do
        result = subject.call(**params)

        expect(result.failure?).to be(true)
        expect(result.failure).to eq([
          "filter AirportOrderField DISTANCE_TO_GEO_POSITION is useless unless geo_position is defined"
        ])
      end
    end
  end
end
