RSpec.describe Models::Airport do
  before(:all) do
    create_spec_airports
  end

  after(:all) do
    delete_spec_airports
  end

  describe '#filter_by_geo_position' do
    let(:geo_position) { { latitude: 46.904732, longitude: 15.702838 } }

    context 'if a radius is given' do
      let(:radius) { { radius: 360000 } }

      fit 'returns airports filtered by geo position' do
        airports = described_class.filter_by_geo_position(geo_position.merge(radius))
        expect(airports.length).to be(2)
        expect(airports.map { |airport| airport.name }).to eq([
          'Salzburg Airport',
          'Vienna International Airport'
        ])
      end
    end

    context 'if a radius is not given' do
      let(:radius) { { radius: nil } }

      it 'returns airports filtered by geo position' do
        airports = described_class.filter_by_geo_position(geo_position.merge(radius))
        expect(airports.length).to be(4)
        expect(airports.map { |airport| airport.name }).to eq([
          'Salzburg Airport',
          'Vienna International Airport',
          'John F. Kennedy International Airport',
          'Logan International Airport'
        ])
      end
    end
  end
end
