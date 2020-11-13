RSpec.describe Schema do
  after(:all) do
    delete_spec_airports
  end

  describe '#airport' do
    before(:context) do
      create_spec_airports
    end

    after(:context) do
      delete_spec_airports
    end

    let(:query) do
     <<-GRAPHQL
        query($id: ID!){
          airport(id: $id) {
            id
            iataCode
            name
          }
        }
      GRAPHQL
    end

    let(:variables) { { id: id } }

    context 'when id is known' do
      let(:id) { 1 }
      fit 'should return the airport' do
        result = described_class.execute(query, variables: variables)
        airport_result = result['data']['airport']
        expect(airport_result).to eq({
          "id"       => "1",
          "iataCode" => "SZG",
          "name"     => "Salzburg Airport"
        })
      end
    end

    context 'when id is unknown' do
      let(:id) { 0 }
      it 'should return no airport' do
        result = described_class.execute(query, variables: variables)
        airport_result = result['data']['airport']
        expect(airport_result).to eq(nil)
      end
    end
  end

  describe '#search_airports' do
    before(:context) do
      create_list(:airport, 10)
    end

    after(:context) do
      delete_spec_airports
    end

    let(:query) do
      <<-GRAPHQL
        query ($after: String, $first: Int, $parameters: AirportSearchParameters) {
          searchAirports(after: $after, first: $first, parameters: $parameters) {
            totalCount
            pageInfo {
              startCursor
              endCursor
              hasNextPage
              hasPreviousPage

            }
            edges {
              node {
                id
                iataCode
                name
              }
            }
          }
        }
      GRAPHQL
    end

    context 'with empty variables' do
      let(:variables) { {} }
      it 'should return the first 100 airports' do
        result = described_class.execute(query, variables: variables)
        expect(result['data']['searchAirports']['totalCount']).to be(110)
        expect(result['data']['searchAirports']['pageInfo']['hasNextPage']).to be(true)
        expect(result['data']['searchAirports']['pageInfo']['hasPreviousPage']).to be(false)
        expect(result['data']['searchAirports']['edges'].length).to be 100
      end
    end

    describe 'pagination' do
      let(:variables) { { first: 15, after: @after } }
      fit 'should return paginated results' do

        hasPreviousPage = []
        hasNextPage = []
        edgeCounts = []
        ids = []

        loop do
          result = described_class.execute(query, variables: variables.merge(after: @after))
          hasPreviousPage << result['data']['searchAirports']['pageInfo']['hasPreviousPage']
          hasNextPage << result['data']['searchAirports']['pageInfo']['hasNextPage']
          edgeCounts << result['data']['searchAirports']['edges'].length
          ids << result['data']['searchAirports']['edges'].map { |edge| edge['node']['id'] }
          break if !result['data']['searchAirports']['pageInfo']['hasNextPage']
          @after = result['data']['searchAirports']['pageInfo']['endCursor']
        end

        expect(hasPreviousPage).to eq([false, true, true, true])
        expect(hasNextPage).to eq([true, true, true, false])
        expect(edgeCounts).to eq([3, 3, 3, 1])
      end
    end
  end
end
