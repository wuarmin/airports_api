RSpec.describe Services::CreateUser do
  describe '#call' do
    let(:params) do
      {
        email: 'pacey.whitter@dawsonscreak.com',
        password: 'abc123'
      }
    end

    context 'when params are valid' do
      it 'should create a brand new user' do
        result = subject.call(**params)

        expect(result.success?).to be(true)
        expect(result.value!.email).to eq('pacey.whitter@dawsonscreak.com')
      end
    end

    context 'when params are invalid' do

      context 'empty hash' do
        let(:params) { {} }

        it 'should fail with errors' do
          result = subject.call(params)

          expect(result.success?).to be(false)
          expect(result.failure).to eq([
            "email is missing",
            "password is missing"
          ])
        end
      end

      context 'invalid data' do
        before(:each) do
          params[:email] = '123'
          params[:password] = 1
        end

        it 'should fail with errors' do
          result = subject.call(params)

          expect(result.success?).to be(false)
          expect(result.failure).to eq(["password must be a string", "email is invalid"])
        end
      end

      context 'email that exists already' do
        before(:each) do
          create(:user, { email: 'pacey.whitter@dawsonscreak.com' })
        end

        it 'should fail with errors' do
          result = subject.call(params)

          expect(result.success?).to be(false)
          expect(result.failure).to eq(["email has already been taken"])
        end
      end
    end
  end
end
