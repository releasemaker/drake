# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ReposController, type: :request do
  let(:user) { FactoryBot.create(:user, :with_credentials) }
  let(:json_body) { JSON.parse(response.body) }

  describe 'GET /api/repos' do
    let(:do_the_thing) { get '/api/repos', params: params }
    let(:params) { {} }

    it_behaves_like :authenticated_api_endpoint

    context 'when logged in' do
      before(:each) do
        login_user user
      end
      let!(:member_repo) { FactoryBot.create(:github_repo) }
      let!(:nonmember_repo) { FactoryBot.create(:github_repo) }
      let!(:membership) { FactoryBot.create(:repo_membership, repo: member_repo, user: user) }

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

  describe 'POST /api/repos/gh/:owner/:repo' do
    let(:do_the_thing) {
      post "/api/repos/gh/#{owner_name}/#{repo_name}", params: params_body, headers: headers
    }
    let(:owner_name) { "octocat" }
    let(:repo_name) { "Hello-World" }
    let(:params_body) { params.to_json }
    let(:params) {
      {
        repo: {
          isEnabled: true,
        },
      }
    }
    let(:headers) {
      {
        'CONTENT_TYPE' => 'application/json',
      }
    }

    it_behaves_like :authenticated_api_endpoint

    context 'when logged in' do
      before(:each) do
        login_user user
      end
      let(:repo_attributes) { FactoryBot.attributes_for(:github_repo) }

      before(:each) do
        allow(RepoProviderWebhookService).to receive(:new).and_return(repo_provider_webhook_service)
      end
      let(:repo_provider_webhook_service) {
        instance_double(RepoProviderWebhookService, perform!: true)
      }

      before do
        allow(PresentGithubRepoByName).to receive(:new).and_return(present_github_repo_by_name)
      end
      let(:present_github_repo_by_name) {
        instance_double(PresentGithubRepoByName, repo: repo)
      }
      let!(:repo) {
        FactoryBot.create(
          :github_repo,
          name: "#{owner_name}/#{repo_name}",
          provider_uid_or_url: '1296269',
          enabled: false,
        )
      }
      let!(:membership) { FactoryBot.create(:repo_membership, :admin, repo: repo, user: user) }

      it 'uses PresentGithubRepoByName to find or create the GithubRepo record' do
        do_the_thing
        expect(PresentGithubRepoByName).to have_received(:new).with(
          owner_name: owner_name,
          repo_name: repo_name,
          user: user,
        )
      end

      context 'when the repo_name has a . in it' do
        let(:repo_name) { "Hello.World" }

        it 'enables the repo' do
          expect { do_the_thing }.to change { repo.reload.enabled }.to be_truthy
        end
      end

      context 'when the current user is an admin on the repo' do
        it 'enables the repo' do
          expect { do_the_thing }.to change { repo.reload.enabled }.to be_truthy
        end

        it 'updates the webhook' do
          do_the_thing
          expect(RepoProviderWebhookService).to have_received(:new).with(repo)
        end

        it 'responds with Created' do
          do_the_thing
          expect(response).to have_http_status(:created)
        end

        it 'responds with JSON containing the new repo' do
          do_the_thing
          expect(json_body['repo']).to include(
            {
              'isEnabled' => true,
              'repoType' => 'gh',
              'providerUid' => '1296269',
              'name' => 'octocat/Hello-World',
              'ownerName' => 'octocat',
              'repoName' => 'Hello-World',
              'path' => '/gh/octocat/Hello-World',
            },
          )
        end
      end

      context 'when the current user is not an admin on the repo' do
        let!(:membership) { FactoryBot.create(:repo_membership, repo: repo, user: user) }

        it 'does not enable the repo' do
          expect {
            begin
              do_the_thing
            rescue
              CanCan::AccessDenied
            end
          }.not_to change { repo.reload.enabled }
        end

        it 'does not update the webhook' do
          expect { do_the_thing }.to raise_error(CanCan::AccessDenied)
          expect(RepoProviderWebhookService).not_to have_received(:new)
        end

        it 'responds with Access Denied' do
          expect { do_the_thing }.to raise_error(CanCan::AccessDenied)
        end
      end
    end
  end

  describe 'GET /api/repos/gh/:owner/:repo' do
    let(:do_the_thing) { get "/api/repos/gh/#{repo.owner_name}/#{repo.repo_name}" }
    let!(:repo) { FactoryBot.create(:github_repo) }

    it_behaves_like :authenticated_api_endpoint

    context 'when logged in' do
      before(:each) do
        login_user user
      end

      before do
        allow(PresentGithubRepoByName).to receive(:new).and_return(present_github_repo_by_name)
      end
      let(:present_github_repo_by_name) {
        instance_double(PresentGithubRepoByName, repo: repo)
      }

      let!(:membership) { FactoryBot.create(:repo_membership, repo: repo, user: user) }

      it 'uses PresentGithubRepoByName to find or create the GithubRepo record' do
        do_the_thing
        expect(PresentGithubRepoByName).to have_received(:new).with(
          owner_name: repo.owner_name,
          repo_name: repo.repo_name,
          user: user,
        )
      end

      context 'with the name of a repo that exists and is accessible to the user' do
        it 'responds with OK' do
          do_the_thing
          expect(response).to have_http_status(:ok)
        end

        it 'responds with JSON containing repo' do
          do_the_thing
          expect(json_body).to include('repo')
          expect(json_body['repo']).to eq(
            'isEnabled' => true,
            'repoType' => 'gh',
            'providerUid' => repo.provider_uid_or_url,
            'ownerName' => repo.owner_name,
            'repoName' => repo.repo_name,
            'name' => repo.name,
            'path' => "/gh/#{repo.owner_name}/#{repo.repo_name}",
          )
        end
      end

      context 'when the repository does not exist' do
        before do
          allow(present_github_repo_by_name).to receive(:repo).and_return(nil)
        end

        it 'responds with Not Found' do
          expect { do_the_thing }.to raise_error(CanCan::AccessDenied)
        end
      end

      context 'when the user does not have access to the repository' do
        let!(:membership) { nil }

        it 'responds with Not Found' do
          expect { do_the_thing }.to raise_error(CanCan::AccessDenied)
        end
      end
    end
  end

  describe 'PATCH /api/repos/gh/:owner/:repo' do
    let(:do_the_thing) {
      patch "/api/repos/gh/#{repo.owner_name}/#{repo.repo_name}", params: params_body, headers: headers
    }
    let(:params_body) { params.to_json }
    let(:params) {
      {repo: repo_attributes}
    }
    let(:headers) {
      {
        'CONTENT_TYPE' => 'application/json',
      }
    }
    let(:repo) { FactoryBot.create(:github_repo) }
    let(:repo_attributes) { {} }

    it_behaves_like :authenticated_api_endpoint

    context 'when logged in' do
      before(:each) do
        login_user user
      end

      before(:each) do
        allow(RepoProviderWebhookService).to receive(:new).and_return(repo_provider_webhook_service)
      end
      let(:repo_provider_webhook_service) {
        instance_double(RepoProviderWebhookService, perform!: true)
      }

      before do
        allow(PresentGithubRepoByName).to receive(:new).and_return(present_github_repo_by_name)
      end
      let(:present_github_repo_by_name) {
        instance_double(PresentGithubRepoByName, repo: repo)
      }

      let!(:membership) { FactoryBot.create(:repo_membership, :admin, repo: repo, user: user) }

      it 'uses PresentGithubRepoByName to find or create the GithubRepo record' do
        do_the_thing
        expect(PresentGithubRepoByName).to have_received(:new).with(
          owner_name: repo.owner_name,
          repo_name: repo.repo_name,
          user: user,
        )
      end

      context 'with a repo that the user is an admin of' do
        context 'disabling' do
          let(:repo_attributes) { {isEnabled: false} }

          it 'updates the repo' do
            expect { do_the_thing }.to change { repo.reload.enabled }.to be_falsey
          end

          it 'updates the webhook' do
            do_the_thing
            expect(RepoProviderWebhookService).to have_received(:new).with(repo)
          end

          it 'responds with OK' do
            do_the_thing
            expect(response).to have_http_status(:ok)
          end

          it 'responds with JSON containing the updated repo' do
            do_the_thing
            expect(json_body).to include('repo')
            expect(json_body['repo']).to eq(
              'isEnabled' => false,
              'repoType' => 'gh',
              'providerUid' => repo.provider_uid_or_url,
              'name' => repo.name,
              'ownerName' => repo.owner_name,
              'repoName' => repo.repo_name,
              'path' => "/gh/#{repo.owner_name}/#{repo.repo_name}",
            )
          end
        end

        context 'enabling' do
          let(:repo) { FactoryBot.create(:github_repo, enabled: false) }
          let(:repo_attributes) { {isEnabled: true} }

          it 'updates the repo' do
            expect { do_the_thing }.to change { repo.reload.enabled }.to be_truthy
          end

          it 'updates the webhook' do
            do_the_thing
            expect(RepoProviderWebhookService).to have_received(:new).with(repo)
          end

          it 'responds with OK' do
            do_the_thing
            expect(response).to have_http_status(:ok)
          end

          it 'responds with JSON containing the updated repo' do
            do_the_thing
            expect(json_body).to include('repo')
            expect(json_body['repo']).to eq(
              'isEnabled' => true,
              'repoType' => 'gh',
              'providerUid' => repo.provider_uid_or_url,
              'name' => repo.name,
              'ownerName' => repo.owner_name,
              'repoName' => repo.repo_name,
              'path' => "/gh/#{repo.owner_name}/#{repo.repo_name}",
            )
          end
        end

        context 'changing nothing' do
          let(:repo) { FactoryBot.create(:github_repo) }
          let(:repo_attributes) { {enabled: true} }

          it 'updates the webhook' do
            do_the_thing
            expect(RepoProviderWebhookService).to have_received(:new).with(repo)
          end

          it 'responds with OK' do
            do_the_thing
            expect(response).to have_http_status(:ok)
          end

          it 'responds with JSON containing the updated repo' do
            do_the_thing
            expect(json_body).to include('repo')
            expect(json_body['repo']).to eq(
              'isEnabled' => true,
              'repoType' => 'gh',
              'providerUid' => repo.provider_uid_or_url,
              'name' => repo.name,
              'ownerName' => repo.owner_name,
              'repoName' => repo.repo_name,
              'path' => "/gh/#{repo.owner_name}/#{repo.repo_name}",
            )
          end
        end
      end

      context 'with a repo that the user is not a member of' do
        let!(:membership) { nil }

        it 'responds with Access Denied' do
          expect { do_the_thing }.to raise_error(CanCan::AccessDenied)
        end
      end

      context 'with a repo for which the user is not an admin' do
        let!(:membership) { FactoryBot.create(:repo_membership, repo: repo, user: user) }

        it 'responds with Access Denied' do
          expect { do_the_thing }.to raise_error(CanCan::AccessDenied)
        end
      end
    end
  end
end
