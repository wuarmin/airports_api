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
      it 'should return the airport' do
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

    context 'when params are valid' do
      context 'when variables are empty' do
        let(:variables) { {} }
        it 'should return the first 3 airports, because GQL_MAX_PAGE_SIZE is set to 3' do
          result = described_class.execute(query, variables: variables)
          expect(result['data']['searchAirports']['totalCount']).to be(10)
          expect(result['data']['searchAirports']['pageInfo']['hasNextPage']).to be(true)
          expect(result['data']['searchAirports']['pageInfo']['hasPreviousPage']).to be(false)
          expect(result['data']['searchAirports']['edges'].length).to be 3
        end
      end

      describe 'ordering' do
        context 'when sort_order is not set' do
          let(:variables) { { parameters: { orderDefinition: [{ field: "NAME" }] } } }

          it 'should sort ascending by default' do
            result = described_class.execute(query, variables: variables)
            names = result['data']['searchAirports']['edges'].map { |edge| edge['node']['name'] }
            sorted_names = names.sort
            expect(names).to eq(sorted_names)
          end
        end
      end

      describe 'pagination' do
        let(:variables) { { first: 15, after: @after } }
        it 'should return paginated results' do

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

    context 'when params are invalid' do
      context 'when there is an invalid variable-name' do
        let(:variables) { { asdasdsad: 15 } }
        it 'should skip the invalid variable and return the valid result' do
          result = described_class.execute(query, variables: variables)
          expect(result['data']['searchAirports']['edges'].length).to be 3
        end
      end

      context 'when there is an invalid variable-value' do
        let(:variables) { { first: "invalid" } }
        it 'should fail with a meaningful error' do
          result = described_class.execute(query, variables: variables)
          expect(result['errors']).to eq([
            {
              "message"    => "Variable $first of type Int was provided invalid value",
              "locations"  => [
                {
                  "line"   => 1,
                  "column" => 32
                }
              ],
              "extensions" => {
                "value"    => "invalid",
                "problems" => [
                  {
                    "path"        => [],
                    "explanation" => "Could not coerce value \"invalid\" to Int"
                  }
                ]
              }
            }
          ])
        end
      end

      context 'when results should be sorted by DISTANCE_TO_GEO_POSITION, but geo position is not defined' do
        let(:variables) { { parameters: { orderDefinition: [{ field: "DISTANCE_TO_GEO_POSITION" }] } } }
        it 'should fail with a meaningful error' do
          result = described_class.execute(query, variables: variables)
          expect(result['errors']).to eq([
            {
              "message"   => "AirportOrderField DISTANCE_TO_GEO_POSITION is useless unless geo_position is defined",
              "locations" => [
                {
                  "line"   => 2,
                  "column" => 11
                }
              ],
              "path"      => [
                "searchAirports"
              ]
            }
          ])
        end
      end
    end
  end
end
