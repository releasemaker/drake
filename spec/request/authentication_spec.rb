require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  describe "GET /auth/github/callback" do
    let(:do_the_thing) { get "/auth/github/callback" }

    context 'when authentication fails' do
      before do
        OmniAuth.config.mock_auth[:github] = :invalid_credentials
      end

      it "sets a flash message" do
        do_the_thing
        expect(response)
          .to redirect_to("#{oauth_failure_path}?message=invalid_credentials&strategy=github")
      end
    end

    context 'when authentication succeeds' do
      before do
        OmniAuth.config.add_mock(
          :github,
          provider: 'github',
          uid: uid,
          info: {
            email: email,
            nickname: nickname,
          },
        )
        Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
      end
      let(:user_identity_info) { FactoryGirl.build(:user_identity) }
      let(:uid) { user_identity_info.uid }
      let(:email) { user_identity_info.email }
      let(:nickname) { user_identity_info.nickname }

      it "creates a user" do
        expect { do_the_thing }.to change { User.count }.by(1)
      end
      it 'sets up the user_identity' do
        do_the_thing
        expect(User.last.nickname).to eq(nickname)
        expect(User.last.email).to eq(email)
        expect(User.last.user_identities.first.uid).to eq(uid)
      end
      it 'signs the user in' do
        do_the_thing
        expect(controller).to be_logged_in
      end
      it "redirects to the root" do
        expect(do_the_thing).to redirect_to(root_path)
      end

      context 'when the user has previously signed in' do
        let!(:user_identity) { FactoryGirl.create(:user_identity) }
        let(:uid) { user_identity.uid }

        it "does not create a user" do
          expect { do_the_thing }.to_not change { User.count }
        end
        it 'updates the existing user_identity' do
          do_the_thing
          user_identity.reload
          expect(user_identity.nickname).to eq(nickname)
          expect(user_identity.email).to eq(email)
        end
        it 'signs the user in' do
          do_the_thing
          expect(controller.current_user).to eq(user_identity.user)
        end
        it "redirects to the root" do
          expect(do_the_thing).to redirect_to(root_path)
        end
      end

      context 'when the user is already signed in with another provider' do
        let(:user) { FactoryGirl.create(:user, :with_credentials) }
        let!(:gitlab_identity) {
          FactoryGirl.build(:user_identity, user: user, provider: 'gitlab')
        }
        before do
          login_user user
        end
        let(:user_identity_info) { FactoryGirl.build(:user_identity, user: user) }

        it "does not create a user" do
          expect { do_the_thing }.to_not change { User.count }
        end
        it 'creates a new user_identity' do
          do_the_thing
          expect(UserIdentity.last.nickname).to eq(nickname)
          expect(UserIdentity.last.email).to eq(email)
        end
        it 'leaves the user signed in' do
          do_the_thing
          expect(controller).to be_logged_in
        end
        it "redirects to the root" do
          expect(do_the_thing).to redirect_to(root_path)
        end

        context 'and the given identity is already associated with another user' do
          let(:user_identity_info) { FactoryGirl.create(:user_identity) }

          it "does not create a user" do
            expect { do_the_thing }.to_not change { User.count }
          end
          it 'does not create a new user_identity' do
            expect { do_the_thing }.to_not change { UserIdentity.count }
          end
          it 'leaves the user signed in' do
            do_the_thing
            expect(controller).to be_logged_in
          end
          it "redirects to the root" do
            expect(do_the_thing).to redirect_to(root_path)
          end
          it "tells the user why it failed" do
            do_the_thing
            expect(controller).to set_flash[:notice].to(/That Github account is already taken/)
          end
        end
      end
    end
  end

  describe "GET /auth/failure" do
    let(:do_the_thing) { get "/auth/failure", params: params }
    let(:params) { { message: 'invalid_credentials', strategy: 'github' } }

    it "sets a flash message" do
      do_the_thing
      expect(controller).to set_flash[:notice].to(/went wrong during authentication with Github/)
    end

    it "redirects to root" do
      do_the_thing
      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE /sign-out" do
    let(:do_the_thing) { delete "/sign-out" }
    before do
      login_user user
    end
    let(:user) { FactoryGirl.create(:user, :with_credentials) }

    it "signs the user out" do
      do_the_thing
      expect(controller).to_not be_logged_in
    end

    it "redirects to the home page" do
      expect(do_the_thing).to redirect_to(root_path)
    end
  end

  describe 'GET /sign-in' do
    let(:the_request) { get "/sign-in", params: { format: :html } }

    context 'when not signed in' do
      it 'responds with Success' do
        the_request
        expect(response).to be_ok
      end

      it 'renders the Sign In form' do
        the_request
        expect(response.body).to have_tag('form[action="/sign-in"]') do
          with_tag('input[type="email"]')
          with_tag('input[type="password"]')
        end
      end
    end
    context 'when signed in' do
      before do
        login_user user
      end
      let(:user) { FactoryGirl.create(:user, :with_credentials) }

      it 'redirects to the dashboard page' do
        the_request
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe 'POST /sign-in' do
    let(:the_request) { post "/sign-in", params: params.merge(format: :html) }
    let(:params) {
      {
        user: {
          email: user.email,
          password: password,
        }
      }
    }
    let(:user) { FactoryGirl.create(:user, :with_credentials, password: password) }
    let(:password) { 'p4ssw0rd' }

    context 'with valid credentials' do
      it 'redirects to the root page' do
        expect(the_request).to redirect_to(root_path)
      end
      it 'signs the user in' do
        the_request
        expect(controller.current_user).to eq(user)
        expect(controller).to be_logged_in
      end
    end

    context 'with an invalid password' do
      let(:params) {
        {
          user: {
            email: user.email,
            password: 'wrongp5ssword',
          }
        }
      }
      it 'responds with Unprocessable Entity' do
        the_request
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'presents the form again' do
        the_request
        expect(response.body).to have_tag('form[action="/sign-in"]') do
          with_tag('input[type="email"]')
          with_tag('input[type="password"]')
        end
      end
      it 'flashes a failure message' do
        the_request
        expect(controller).to set_flash.now[:alert].to(/are not valid/)
      end
    end

    context 'with an invalid email' do
      let(:params) {
        {
          user: {
            email: FactoryGirl.generate(:email),
            password: 'wrongp5ssword',
          }
        }
      }
      it 'responds with Unprocessable Entity' do
        the_request
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'presents the form again' do
        the_request
        expect(response.body).to have_tag('form[action="/sign-in"]') do
          with_tag('input[type="email"]')
          with_tag('input[type="password"]')
        end
      end
      it 'flashes a failure message' do
        the_request
        expect(controller).to set_flash.now[:alert].to(/are not valid/)
      end
    end
  end
end
