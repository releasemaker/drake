require 'rails_helper'

RSpec.describe ReposController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

  describe 'GET index' do
    let(:do_the_thing) { get :index }
    context 'when logged in' do
      before(:each) do
        login_user user
      end
      let!(:member_repo) { FactoryGirl.create(:repo) }
      let!(:nonmember_repo) { FactoryGirl.create(:repo) }
      let!(:membership) { FactoryGirl.create(:repo_membership, repo: member_repo, user: user) }

      it 'shows the repos that the user is a member of' do
        do_the_thing
        expect(assigns(:repos)).to include(member_repo)
        expect(assigns(:repos)).to_not include(nonmember_repo)
      end
    end
    context 'without logging in' do
      it 'redirects to authentication' do
        expect(do_the_thing).to redirect_to(root_path)
      end
    end
  end

  describe 'GET new' do
    let(:do_the_thing) { get :new }
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
        expect(assigns(:available_repos).first).to have_attributes(name: 'octocat/Hello-World')
      end
    end
    context 'without logging in' do
      it 'redirects to authentication' do
        expect(do_the_thing).to redirect_to(root_path)
      end
    end
  end

  describe 'POST create' do
    let(:do_the_thing) { post :create, repo: new_repo_attributes }
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
        let!(:existing_repo) { FactoryGirl.create(:repo, new_repo_attributes) }
        it 'does not create the Repo' do
          pending "TODO"
          expect { do_the_thing }.to_not change { Repo.count }
        end
        it 'adds a RepoMembership for the current user' do
          pending "TODO"
          do_the_thing
          expect(RepoMembership.last).to have_attributes(user: current_user, repo: existing_repo)
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
end
