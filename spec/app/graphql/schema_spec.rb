RSpec.describe Schema do

  describe 'queries' do
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

      let(:id) { 1 }
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

      context 'when unauthorized' do
        it 'should return an unauthorized-error' do
          result = described_class.execute(query, variables: variables)

          expect(result['data']['airport']).to be_nil
          expect(result['errors']).to eq([
            {
              "message"    => "401 Unauthorized",
              "locations"  => [
                {
                  "line"   => 2,
                  "column" => 13
                }
              ],
              "path"       => [
                "airport"
              ],
              "extensions" => {
                "code" => "UNAUTHORIZED"
              }
            }
          ])
        end
      end

      context 'when authorized' do
        let(:context) { { current_user: { id: 1 } } }

        context 'when id is known' do
          it 'should return the airport' do
            result = described_class.execute(query, variables: variables, context: context)
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

      context 'when unauthorized' do
        it 'should return an unauthorized-error' do
          result = described_class.execute(query, variables: {})

          expect(result['data']).to be_nil
          expect(result['errors']).to eq([
            {
              "message"    => "401 Unauthorized",
              "locations"  => [
                {
                  "line"   => 2,
                  "column" => 13
                }
              ],
              "path"       => [
                "searchAirports"
              ],
              "extensions" => {
                "code" => "UNAUTHORIZED"
              }
            }
          ])
        end
      end

      context 'when authorized' do
        let(:context) { { current_user: { id: 1 } } }

        context 'when params are valid' do
          context 'when variables are empty' do
            let(:variables) { {} }
            it 'should return the first 3 airports, because GQL_MAX_PAGE_SIZE is set to 3' do
              result = described_class.execute(query, variables: variables, context: context)
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
                result = described_class.execute(query, variables: variables, context: context)
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
                result = described_class.execute(query, variables: variables.merge(after: @after), context: context)
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
              result = described_class.execute(query, variables: variables, context: context)
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
                      "column" => 34
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
              result = described_class.execute(query, variables: variables, context: context)
              expect(result['errors']).to eq([
                {
                  "message"   => "AirportOrderField DISTANCE_TO_GEO_POSITION is useless unless geo_position is defined",
                  "locations" => [
                    {
                      "line"   => 2,
                      "column" => 13
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
  end

  describe 'mutations' do
    describe '#create_user' do
      let(:mutation) do
        <<-GRAPHQL
          mutation ($credentials: AuthCredentials!) {
            createUser(credentials: $credentials) {
              id
              email
            }
          }
        GRAPHQL
      end

      context 'when unauthorized' do
        let(:variables) { { credentials: { email: 'pacey.whitter@dawsonscreak.com', password: 'password' } } }

        it 'should return an unauthorized-error' do
          result = described_class.execute(mutation, variables: variables)

          expect(result['data']).to be_nil
          expect(result['errors']).to eq([
            {
              "message"    => "401 Unauthorized",
              "locations"  => [
                {
                  "line"   => 2,
                  "column" => 13
                }
              ],
              "path"       => [
                "createUser"
              ],
              "extensions" => {
                "code" => "UNAUTHORIZED"
              }
            }
          ])
        end
      end

      context 'when authorized' do
        let(:context) { { current_user: { id: 1 } } }

        context 'when params are valid' do
          let(:variables) { { credentials: { email: 'pacey.whitter@dawsonscreak.com', password: 'password' } } }
          it 'should create a user' do
            result = described_class.execute(mutation, variables: variables, context: context)
            expect(result['data']['createUser']['email']).to eq('pacey.whitter@dawsonscreak.com')
          end

          context 'but email is taken' do
            before(:each) do
              create(:user, { email: 'pacey.whitter@dawsonscreak.com' })
            end

            it 'should fail with a specific error' do
              result = described_class.execute(mutation, variables: variables, context: context)

              expect(result['errors']).to eq([
                {
                  "message"   => "email has already been taken",
                  "locations" => [
                    {
                      "line"   => 2,
                      "column" => 13
                    }
                  ],
                  "path"      => [
                    "createUser"
                  ]
                }
              ])
            end
          end
        end

        context 'when params are invalid' do
          context 'when params are nil' do
            let(:variables) { nil }

            it 'should fail with errors' do
              result = described_class.execute(mutation, variables: variables, context: context)

              expect(result['errors']).to eq([
                {
                  "message"    => "Variable $credentials of type AuthCredentials! was provided invalid value",
                  "locations"  => [
                    {
                      "line"   => 1,
                      "column" => 21
                    }
                  ],
                  "extensions" => {
                    "value"    => nil,
                    "problems" => [
                      {
                        "path"        => [],
                        "explanation" => "Expected value to not be null"
                      }
                    ]
                  }
                }
              ])
            end
          end

          context 'when params are empty' do
            let(:variables) { {} }

            it 'should fail with errors' do
              result = described_class.execute(mutation, variables: variables, context: context)

              expect(result['errors']).to eq([
                {
                  "message"    => "Variable $credentials of type AuthCredentials! was provided invalid value",
                  "locations"  => [
                    {
                      "line"   => 1,
                      "column" => 21
                    }
                  ],
                  "extensions" => {
                    "value"    => nil,
                    "problems" => [
                      {
                        "path"        => [],
                        "explanation" => "Expected value to not be null"
                      }
                    ]
                  }
                }
              ])
            end
          end

          context 'when credentials are nil' do
            let(:variables) { { credentials: nil } }

            it 'should fail with errors' do
              result = described_class.execute(mutation, variables: variables, context: context)

              expect(result['errors']).to eq([
                {
                  "message"    => "Variable $credentials of type AuthCredentials! was provided invalid value",
                  "locations"  => [
                    {
                      "line"   => 1,
                      "column" => 21
                    }
                  ],
                  "extensions" => {
                    "value"    => nil,
                    "problems" => [
                      {
                        "path"        => [],
                        "explanation" => "Expected value to not be null"
                      }
                    ]
                  }
                }
              ])
            end
          end

          context 'when credentials are empty' do
            let(:variables) { { credentials: {} } }

            it 'should fail with errors' do
              result = described_class.execute(mutation, variables: variables, context: context)

              expect(result['errors']).to eq([
                {
                  "message"    => "Variable $credentials of type AuthCredentials! was provided invalid value for email (Expected value to not be null), password (Expected value to not be null)",
                  "locations"  => [
                    {
                      "line"   => 1,
                      "column" => 21
                    }
                  ],
                  "extensions" => {
                    "value"    => {},
                    "problems" => [
                      {
                        "path"        => [
                          "email"
                        ],
                        "explanation" => "Expected value to not be null"
                      },
                      {
                        "path"        => [
                          "password"
                        ],
                        "explanation" => "Expected value to not be null"
                      }
                    ]
                  }
                }
              ])
            end
          end

          context 'when email is invalid' do
            let(:variables) { { credentials: { email: 'invalid', password: 'abc123' } } }

            it 'should fail with errors' do
              result = described_class.execute(mutation, variables: variables, context: context)

              expect(result['errors']).to eq([
                {
                  "message"   => "email is invalid",
                  "locations" => [
                    {
                      "line"   => 2,
                      "column" => 13
                    }
                  ],
                  "path"      => [
                    "createUser"
                  ]
                }
              ])
            end
          end

          context 'when password is invalid' do
            let(:variables) { { credentials: { email: 'email@test.com', password: '' } } }

            it 'should fail with errors' do
              result = described_class.execute(mutation, variables: variables, context: context)

              expect(result['errors']).to eq([
                {
                  "message"   => "password must be filled",
                  "locations" => [
                    {
                      "line"   => 2,
                      "column" => 13
                    }
                  ],
                  "path"      => [
                    "createUser"
                  ]
                }
              ])
            end
          end

          context 'when password has wrong data type' do
            let(:variables) { { credentials: { email: 'email@test.com', password: 45454 } } }

            it 'should fail with errors' do
              result = described_class.execute(mutation, variables: variables, context: context)

              expect(result['errors']).to eq([
                {
                  "message"    => "Variable $credentials of type AuthCredentials! was provided invalid value for password (Could not coerce value 45454 to String)",
                  "locations"  => [
                    {
                      "line"   => 1,
                      "column" => 21
                    }
                  ],
                  "extensions" => {
                    "value"    => {
                      "email"    => "email@test.com",
                      "password" => 45454
                    },
                    "problems" => [
                      {
                        "path"        => [
                          "password"
                        ],
                        "explanation" => "Could not coerce value 45454 to String"
                      }
                    ]
                  }
                }
              ])
            end
          end
        end
      end

    end

    describe '#sign_in' do
      let(:mutation) do
        <<-GRAPHQL
          mutation ($credentials: AuthCredentials!) {
            signIn(credentials: $credentials) {
              user {
                id
                email
              }
              token
            }
          }
        GRAPHQL
      end

      context 'when params are valid' do
        let(:email) { 'pacey.whitter@dawsonscreak.com' }
        let(:password) { 'my password' }
        let(:variables) { { credentials: { email: email, password: password } } }

        context 'when user with given email exists' do
          before(:each) do
            create(:user, { email: 'pacey.whitter@dawsonscreak.com' })
          end

          context('when password matches') do
            it 'should sign in a user' do
              result = described_class.execute(mutation, variables: variables)

              expect(result['data']['signIn']['user']['email']).to eq('pacey.whitter@dawsonscreak.com')
              expect(result['data']['signIn']['token'].length).to be(127)
            end
          end

          context 'when password does not match' do
            let(:password) { 'not my password' }

            it 'should fail with an error' do
              result = described_class.execute(mutation, variables: variables)

              expect(result['errors']).to eq([
                {
                  "message"   => "authentication failed",
                  "locations" => [
                    {
                      "line"   => 2,
                      "column" => 13
                    }
                  ],
                  "path"      => [
                    "signIn"
                  ]
                }
              ])
            end
          end
        end

        context 'when there is no user with given email' do
          let(:email) { 'joey.potter@dawsonscreak.com' }

          it 'should fail with an error' do
            result = described_class.execute(mutation, variables: variables)

            expect(result['errors']).to eq([
              {
                "message"   => "no user found for given email",
                "locations" => [
                  {
                    "line"   => 2,
                    "column" => 13
                  }
                ],
                "path"      => [
                  "signIn"
                ]
              }
            ])
          end
        end
      end

      context 'when params are invalid' do
        context 'when params are nil' do
          let(:variables) { nil }

          it 'should fail with errors' do
            result = described_class.execute(mutation, variables: variables)

            expect(result['errors']).to eq([
              {
                "message"    => "Variable $credentials of type AuthCredentials! was provided invalid value",
                "locations"  => [
                  {
                    "line"   => 1,
                    "column" => 21
                  }
                ],
                "extensions" => {
                  "value"    => nil,
                  "problems" => [
                    {
                      "path"        => [],
                      "explanation" => "Expected value to not be null"
                    }
                  ]
                }
              }
            ])
          end
        end

        context 'when params are empty' do
          let(:variables) { {} }

          it 'should fail with errors' do
            result = described_class.execute(mutation, variables: variables)

            expect(result['errors']).to eq([
              {
                "message"    => "Variable $credentials of type AuthCredentials! was provided invalid value",
                "locations"  => [
                  {
                    "line"   => 1,
                    "column" => 21
                  }
                ],
                "extensions" => {
                  "value"    => nil,
                  "problems" => [
                    {
                      "path"        => [],
                      "explanation" => "Expected value to not be null"
                    }
                  ]
                }
              }
            ])
          end
        end

        context 'when credentials are nil' do
          let(:variables) { { credentials: nil } }

          it 'should fail with errors' do
            result = described_class.execute(mutation, variables: variables)

            expect(result['errors']).to eq([
              {
                "message"    => "Variable $credentials of type AuthCredentials! was provided invalid value",
                "locations"  => [
                  {
                    "line"   => 1,
                    "column" => 21
                  }
                ],
                "extensions" => {
                  "value"    => nil,
                  "problems" => [
                    {
                      "path"        => [],
                      "explanation" => "Expected value to not be null"
                    }
                  ]
                }
              }
            ])
          end
        end

        context 'when credentials are empty' do
          let(:variables) { { credentials: {} } }

          it 'should fail with errors' do
            result = described_class.execute(mutation, variables: variables)

            expect(result['errors']).to eq([
              {
                "message"    => "Variable $credentials of type AuthCredentials! was provided invalid value for email (Expected value to not be null), password (Expected value to not be null)",
                "locations"  => [
                  {
                    "line"   => 1,
                    "column" => 21
                  }
                ],
                "extensions" => {
                  "value"    => {},
                  "problems" => [
                    {
                      "path"        => [
                        "email"
                      ],
                      "explanation" => "Expected value to not be null"
                    },
                    {
                      "path"        => [
                        "password"
                      ],
                      "explanation" => "Expected value to not be null"
                    }
                  ]
                }
              }
            ])
          end
        end

        context 'when email is invalid' do
          let(:variables) { { credentials: { email: 'invalid', password: 'abc123' } } }

          it 'should fail with errors' do
            result = described_class.execute(mutation, variables: variables)

            expect(result['errors']).to eq([
              {
                "message"   => "email is invalid",
                "locations" => [
                  {
                    "line"   => 2,
                    "column" => 13
                  }
                ],
                "path"      => [
                  "signIn"
                ]
              }
            ])
          end
        end

        context 'when password is invalid' do
          let(:variables) { { credentials: { email: 'email@test.com', password: '' } } }

          it 'should fail with errors' do
            result = described_class.execute(mutation, variables: variables)

            expect(result['errors']).to eq([
              {
                "message"   => "password must be filled",
                "locations" => [
                  {
                    "line"   => 2,
                    "column" => 13
                  }
                ],
                "path"      => [
                  "signIn"
                ]
              }
            ])
          end
        end

        context 'when password has wrong data type' do
          let(:variables) { { credentials: { email: 'email@test.com', password: 45454 } } }

          it 'should fail with errors' do
            result = described_class.execute(mutation, variables: variables)

            expect(result['errors']).to eq([
              {
                "message"    => "Variable $credentials of type AuthCredentials! was provided invalid value for password (Could not coerce value 45454 to String)",
                "locations"  => [
                  {
                    "line"   => 1,
                    "column" => 21
                  }
                ],
                "extensions" => {
                  "value"    => {
                    "email"    => "email@test.com",
                    "password" => 45454
                  },
                  "problems" => [
                    {
                      "path"        => [
                        "password"
                      ],
                      "explanation" => "Could not coerce value 45454 to String"
                    }
                  ]
                }
              }
            ])
          end
        end

      end

    end

  end

end
