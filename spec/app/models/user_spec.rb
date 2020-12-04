RSpec.describe Models::User do

  before(:all) do
    create(:user, {
      email: 'pacey.whitter@dawsonscreak.com'
    })
  end

  after(:all) do
    delete_spec_objects(:users)
  end

  describe '#find_by_email' do
    context 'when user with given email is available' do
      it 'should return the user' do
        user = described_class.find_by_email('pacey.whitter@dawsonscreak.com')

        expect(user).to be_instance_of(Models::User)
        expect(user.email).to eq('pacey.whitter@dawsonscreak.com')
      end
    end

    context 'when there is no user with given email' do
      it 'should return nil' do
        user = described_class.find_by_email('joey.potter@dawsonscreak.com')

        expect(user).to be(nil)
      end
    end
  end
end
