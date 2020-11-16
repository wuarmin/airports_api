describe Controllers::GraphQL do
  let(:params) {
    {
      query: "
        {
          airport(id: 1) {
            name
          }
        }
      "
    }
  }

  before do
    create_spec_airports
  end

  it 'is successful' do
    response = subject.call(params)

    expect(response[0]).to be(200)
    expect(response[1]['Content-Type']).to eq('application/json; charset=utf-8')
  end

end
