require 'rails_helper'

RSpec.describe Api::ReposController, type: :request do
  let(:user) { FactoryGirl.create(:user, :with_credentials) }

  describe 'GET /api/repos' do
    let(:do_the_thing) { get '/api/repos', params: params }
    let(:params) { {} }
    let(:json_body) { JSON.parse(response.body) }

    it_behaves_like :authenticated_endpoint

    context 'when logged in' do
      before(:each) do
        login_user user
      end
      let!(:member_repo) { FactoryGirl.create(:github_repo) }
      let!(:nonmember_repo) { FactoryGirl.create(:github_repo) }
      let!(:membership) { FactoryGirl.create(:repo_membership, repo: member_repo, user: user) }

      it 'responds with OK' do
        do_the_thing
        expect(response).to have_http_status(:ok)
      end

      it 'responds with JSON containing repos' do
        do_the_thing
        expect(json_body).to include('repos')
      end

      it 'lists each repository' do
        do_the_thing
        expect(json_body['repos']).to include(
          include(
            'isEnabled' => true,
            'repoType' => 'gh',
            'providerUid' => member_repo.provider_uid_or_url,
            'name' => member_repo.name,
            'path' => member_repo.friendly_path,
          ),
        )
      end

      it 'does not include repos that the user is not a member of' do
        do_the_thing
        expect(json_body['repos']).not_to include(include('name' => nonmember_repo.name))
      end

    end
  end

  describe 'GET /api/repos/gh/:owner/:repo' do
    let(:do_the_thing) { get "/api/repos/gh/#{repo.owner_name}/#{repo.repo_name}" }
    let!(:repo) { FactoryGirl.create(:github_repo) }
    let(:json_body) { JSON.parse(response.body) }

    it_behaves_like :authenticated_endpoint

    context 'when logged in' do
      before(:each) do
        login_user user
      end

      context 'with the name of a repo that exists' do
        context 'that the user is a member of' do
          let!(:membership) { FactoryGirl.create(:repo_membership, repo: repo, user: user) }

          it 'responds with OK' do
            do_the_thing
            expect(response).to have_http_status(:ok)
          end

          it 'responds with JSON containing repo' do
            do_the_thing
            expect(json_body).to include('repo')
            expect(json_body['repo']).to include(
              'isEnabled' => true,
              'repoType' => 'gh',
              'providerUid' => repo.provider_uid_or_url,
              'name' => repo.name,
              'path' => "/gh/#{repo.owner_name}/#{repo.repo_name}",
            )
          end
        end

        context 'that the user is not a member of', vcr: { cassette_name: 'github_repo' } do
          let!(:repo) { FactoryGirl.create(:github_repo, name: "#{owner_name}/#{repo_name}") }
          let(:owner_name) { Rails.configuration.x.github.test_repo_owner_name }
          let!(:user_identity) {
            FactoryGirl.create(
              :user_identity,
              :github,
              user: user,
              token: Rails.configuration.x.github.test_auth_token,
            )
          }

          it 'fetches the repo from github'

          context 'when github grants the user access to the repo' do
            let(:repo_name) { Rails.configuration.x.github.test_repo_name }

            it 'responds with OK' do
              do_the_thing
              expect(response).to have_http_status(:ok)
            end

            it 'responds with JSON containing repo' do
              do_the_thing
              expect(json_body).to include('repo')
              expect(json_body['repo']).to include(
                'isEnabled' => true,
                'repoType' => 'gh',
                'providerUid' => repo.provider_uid_or_url,
                'name' => repo.name,
                'path' => "/gh/#{repo.owner_name}/#{repo.repo_name}",
              )
            end
          end

          context 'when github returns 404' do
            let(:repo_name) { 'definitely-not-a-real-repo--gimme-a-404' }

            it 'does not show the repo' do
              expect { do_the_thing }.to raise_error(ActionController::RoutingError)
            end
          end
        end
      end

      context 'with the name of a repo that does not exist' do
        it 'looks up the repo in Github'

        context 'when the repo exists on Github' do
          it 'creates the repo'

          context 'when Github indicates that the user does not have admin access to the repo' do
            it 'creates non-admin membership for the user'
          end

          context 'when Github indicates that the user has admin access to the repo' do
            it 'creates admin membership for the user'
          end
        end

        context 'when the repo does not exist on Github' do
          it 'responds with Not Found'
        end
      end
    end
  end
end
