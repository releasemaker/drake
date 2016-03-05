require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe "#create" do
    let(:do_the_thing) { get :create, params: { provider: :github } }

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
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
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
        expect { do_the_thing }.to change { controller.current_user }
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
          expect { do_the_thing }.to change { controller.current_user }
        end
        it "redirects to the root" do
          expect(do_the_thing).to redirect_to(root_path)
        end
      end

      context 'when the user is already signed in with another provider' do
        let!(:gitlab_identity) { FactoryGirl.build(:user_identity, provider: 'gitlab') }
        before do
          login_user gitlab_identity.user
        end
        let(:user_identity_info) { FactoryGirl.build(:user_identity, user: gitlab_identity.user) }

        it "does not create a user" do
          expect { do_the_thing }.to_not change { User.count }
        end
        it 'creates a new user_identity' do
          do_the_thing
          expect(UserIdentity.last.nickname).to eq(nickname)
          expect(UserIdentity.last.email).to eq(email)
        end
        it 'leaves the user signed in' do
          expect { do_the_thing }.to_not change { controller.current_user }
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
            expect { do_the_thing }.to_not change { controller.current_user }
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

  describe "#destroy" do
    let(:do_the_thing) { delete :destroy }
    before do
      login_user user
    end
    let(:user) { FactoryGirl.create(:user) }

    it "logs the user out" do
      expect { do_the_thing }.to change { controller.current_user }.to be_nil
    end

    it "redirects to the home page" do
      expect(do_the_thing).to redirect_to(root_path)
    end
  end
end
