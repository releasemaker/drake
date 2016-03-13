require 'rails_helper'

RSpec.describe "Repos", type: :request do
  let(:user) { FactoryGirl.create(:user, :with_credentials) }

  describe 'GET /repos' do
    let(:do_the_thing) { get '/repos' }
    context 'when logged in' do
      before(:each) do
        login_user user
      end
      let!(:member_repo) { FactoryGirl.create(:repo) }
      let!(:nonmember_repo) { FactoryGirl.create(:repo) }
      let!(:membership) { FactoryGirl.create(:repo_membership, repo: member_repo, user: user) }

      it 'shows the repos that the user is a member of' do
        do_the_thing
        expect(response.body).to include(member_repo.name)
        expect(response.body).to_not include(nonmember_repo.name)
      end
    end
    context 'without logging in' do
      it 'redirects to authentication' do
        expect(do_the_thing).to redirect_to(root_path)
      end
    end
  end

  describe 'GET /repos/new' do
    let(:do_the_thing) { get '/repos/new' }
    context 'when logged in' do
      before(:each) do
        login_user user
      end
      let!(:user_identity) { FactoryGirl.create(:user_identity, :github, user: user) }
      let(:api_data) { File.read Rails.root.join(*%w(spec fixtures github_repositories.json)) }
      let!(:api_request) {
        stub_request(:get, %r{https://api\.github\.com/user/repos\?access_token=.+})
          .to_return(body: api_data, status: 200)
      }

      it 'includes a list of repositories from Github' do
        do_the_thing
        expect(response.body).to include("octocat/Hello-World")
      end
      context 'with an existing matching repo' do
        let!(:existing_matching_repo) {
          FactoryGirl.create(
            :github_repo,
            provider_uid_or_url: "1296269",
            name: 'octocat/Hello-World',
          )
        }

        it 'includes the persisted repo' do
          do_the_thing
          expect(response.body).to include('octocat/Hello-World')
        end
      end
    end
    context 'without logging in' do
      it 'redirects to authentication' do
        expect(do_the_thing).to redirect_to(root_path)
      end
    end
  end

  describe 'POST /repos' do
    let(:do_the_thing) { post '/repos', params: { repo: new_repo_attributes } }
    context 'when logged in' do
      before(:each) do
        login_user user
      end
      let(:repo_attributes) { FactoryGirl.attributes_for(:repo) }
      let(:new_repo_attributes) { repo_attributes.slice(:name, :provider_uid_or_url) }
      let(:new_repo) { Repo.find_by(repo_attributes.slice(:type, :provider_uid_or_url)) }

      context 'when the Repo does not exist' do
        it 'creates the Repo' do
          expect { do_the_thing }.to change { Repo.count }.by(1)
          expect(new_repo).to have_attributes(name: new_repo_attributes[:name])
        end
        it 'adds a RepoMembership for the current user' do
          do_the_thing
          expect(RepoMembership.last).to have_attributes(user: user, repo: new_repo)
        end
      end
      context 'when the Repo already exists' do
        let!(:existing_repo) {
          FactoryGirl.create(:repo, new_repo_attributes.merge(enabled: false))
        }

        it 'does not create the Repo' do
          expect { do_the_thing }.to_not change { Repo.count }
        end
        it 'enables the repo' do
          expect { do_the_thing; existing_repo.reload }.to change { existing_repo.enabled }
          expect(existing_repo).to be_enabled
        end
        it 'adds a RepoMembership for the current user' do
          do_the_thing
          expect(RepoMembership.last).to have_attributes(user: user, repo: existing_repo)
        end
        context 'when a RepoMembership for the current user already exists' do
          let!(:existing_repo_membership) {
            FactoryGirl.create(:repo_membership, user: user, repo: existing_repo)
          }
          it 'remains' do
            do_the_thing
            expect(RepoMembership.last).to have_attributes(user: user, repo: existing_repo)
          end
        end
      end
    end
    context 'without logging in' do
      let(:new_repo_attributes) { { name: 'stuff' } }
      it 'redirects to authentication' do
        expect(do_the_thing).to redirect_to(root_path)
      end
    end
  end

  describe 'GET /repos/:id' do
    let(:do_the_thing) { get "/repos/#{repo.to_param}" }
    let!(:repo) { FactoryGirl.create(:repo) }

    context 'when logged in' do
      before(:each) do
        login_user user
      end
      context 'with a repo that the user is a member of' do
        let!(:membership) { FactoryGirl.create(:repo_membership, repo: repo, user: user) }
        it 'shows the repo' do
          do_the_thing
          expect(response.body).to include(repo.name)
        end
      end
      context 'with a repo that the user is not a member of' do
        it 'does not show the repo' do
          expect { do_the_thing }.to raise_error(CanCan::AccessDenied)
        end
      end
    end
    context 'without logging in' do
      it 'redirects to authentication' do
        expect(do_the_thing).to redirect_to(root_path)
      end
    end
  end
end
