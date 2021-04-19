RSpec.describe Services::SignInUser do
  describe "#call" do
    let(:email) { "pacey.whitter@dawsonscreak.com" }
    let(:password) { "my password" }
    let(:params) do
      {
        email: email,
        password: password,
      }
    end

    context "when params are valid" do
      context "when user with given email exists" do
        before(:each) do
          create(:user, { email: "pacey.whitter@dawsonscreak.com" })
        end

        context("when password matches") do
          it "should return a token" do
            result = subject.call(**params)

            expect(result.success?).to be(true)
            expect(result.value![:token].length).to be > 100
          end
        end

        context "when password does not match" do
          let(:password) { "not my password" }

          it "should fail with an error" do
            result = subject.call(**params)

            expect(result.success?).to be(false)
            expect(result.failure).to eq(["authentication failed"])
          end
        end

        context "when there is no user with given email" do
          let(:email) { "joey.potter@dawsonscreak.com" }

          it "should fail with an error" do
            result = subject.call(**params)

            expect(result.success?).to be(false)
            expect(result.failure).to eq(["no user found for given email"])
          end
        end
      end
    end

    context "when params are invalid" do
      context "empty params" do
        let(:params) { {} }

        it "should fail with errors" do
          result = subject.call(params)

          expect(result.success?).to be(false)
          expect(result.failure).to eq([
            "email is missing",
            "password is missing",
          ])
        end
      end

      context "invalid data" do
        before(:each) do
          params[:email] = "123"
          params[:password] = 1
        end

        it "should fail with errors" do
          result = subject.call(params)

          expect(result.success?).to be(false)
          expect(result.failure).to eq(["password must be a string", "email is invalid"])
        end
      end
    end
  end
end
