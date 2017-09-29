require 'rails_helper'

RSpec.describe "Repos", type: :request do
  let(:user) { FactoryGirl.create(:user, :with_credentials) }

  describe 'GET /repos' do
    let(:do_the_thing) { get '/repos' }
    context 'when logged in' do
      before(:each) do
        login_user user
      end
      let!(:member_repo) { FactoryGirl.create(:github_repo) }
      let!(:nonmember_repo) { FactoryGirl.create(:github_repo) }
      let!(:membership) { FactoryGirl.create(:repo_membership, repo: member_repo, user: user) }

      it 'shows the repos that the user is a member of' do
        do_the_thing
        expect(response.body).to have_tag('a', member_repo.name)
        expect(response.body).to_not have_tag('a', nonmember_repo.name)
      end
      it 'links to the friendly URL for the repo' do
        do_the_thing
        expect(response.body).to have_tag(%Q(a[href="/gh/#{member_repo.name}"]), member_repo.name)
      end
    end
    context 'without logging in' do
      it 'redirects to authentication' do
        expect(do_the_thing).to redirect_to(root_path)
      end
    end
  end

  describe 'GET /repos/new' do
    let(:do_the_thing) { get '/repos/new', params: params }
    let(:params) { {} }

    context 'when logged in' do
      before(:each) do
        login_user user
      end
      let!(:user_identity) { FactoryGirl.create(:user_identity, :github, user: user) }
      let(:api_data) { json_fixture('github/repositories') }
      let!(:api_request) {
        stub_request(:get, %r{https://api\.github\.com/user/repos\?access_token=.+})
          .to_return(body: api_data, status: 200)
      }

      context 'without a search term' do
        it 'includes a list of repositories from Github with Add buttons' do
          do_the_thing
          expect(response.body).to have_tag('tr[data-provider-uid="1296269"]') do
            with_tag('td', 'octocat/Hello-World')
            with_submit('Add')
          end
        end
        context 'when the user does not have admin access to the repo' do
          it 'does not include the Add button'
        end
        context 'with an existing matching repo' do
          context 'that is disabled' do
            let!(:existing_matching_repo) {
              FactoryGirl.create(
                :github_repo,
                enabled: false,
                provider_uid_or_url: "1296269",
                name: 'octocat/Hello-World',
              )
            }

            it 'shows the persisted repo with an Add button' do
              do_the_thing
              expect(response.body).to have_tag('tr[data-provider-uid="1296269"]') do
                with_tag('td', 'octocat/Hello-World')
                with_submit('Add')
              end
            end
          end
          context 'that is enabled' do
            let!(:existing_matching_repo) {
              FactoryGirl.create(
                :github_repo,
                enabled: true,
                provider_uid_or_url: "1296269",
                name: 'octocat/Hello-World',
              )
            }

            it 'shows the persisted repo without an Add button' do
              do_the_thing
              expect(response.body).to have_tag('tr[data-provider-uid="1296269"]') do
                with_tag('td', 'octocat/Hello-World')
                with_tag('a', 'Existing')
                without_submit('Add')
              end
            end
          end
        end
      end
      context 'with a search term' do
        let(:params) { { q: search_term } }

        context 'that matches a repo' do
          let(:search_term) { "Hello" }

          it 'includes a list of matching repositories with Add buttons' do
            do_the_thing
            expect(response.body).to have_tag('tr[data-provider-uid="1296269"]') do
              with_tag('td', 'octocat/Hello-World')
              with_submit('Add')
            end
          end
          it 'does not show nonmatching repositories' do
            expect(response.body).to_not have_tag('tr[data-provider-uid="1296270"]')
          end

          context 'with a matching repo exists locally' do
            context 'and is disabled' do
              let!(:existing_matching_repo) {
                FactoryGirl.create(
                  :github_repo,
                  enabled: false,
                  provider_uid_or_url: "1296269",
                  name: 'octocat/Hello-World',
                )
              }

              it 'shows the persisted repo with an Add button' do
                do_the_thing
                expect(response.body).to have_tag('tr[data-provider-uid="1296269"]') do
                  with_tag('td', 'octocat/Hello-World')
                  with_submit('Add')
                end
              end
              it 'does not show nonmatching repositories' do
                expect(response.body).to_not have_tag('tr[data-provider-uid="1296270"]')
              end
            end
            context 'and is enabled' do
              let!(:existing_matching_repo) {
                FactoryGirl.create(
                  :github_repo,
                  enabled: true,
                  provider_uid_or_url: "1296269",
                  name: 'octocat/Hello-World',
                )
              }

              it 'shows the persisted repo with an Add button' do
                do_the_thing
                expect(response.body).to have_tag('tr[data-provider-uid="1296269"]') do
                  with_tag('td', 'octocat/Hello-World')
                  with_tag('a', 'Existing')
                  without_submit('Add')
                end
              end
              it 'does not show nonmatching repositories' do
                expect(response.body).to_not have_tag('tr[data-provider-uid="1296270"]')
              end
            end
          end
        end
        context 'that does not match any repos' do
          let(:search_term) { "zen" }

          it 'does not show any repositories' do
            do_the_thing
            expect(response.body).to_not have_tag('tr[data-provider-uid="1296269"]')
            expect(response.body).to_not have_tag('tr[data-provider-uid="1296270"]')
          end
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
      let(:repo_attributes) { FactoryGirl.attributes_for(:github_repo) }
      let(:new_repo_attributes) { repo_attributes.slice(:name, :provider_uid_or_url) }
      let(:new_repo) { Repo.find_by(repo_attributes.slice(:type, :provider_uid_or_url)) }

      before(:each) do
        allow(RepoProviderWebhookService).to receive(:new).and_return(repo_provider_webhook_service)
      end
      let(:repo_provider_webhook_service) {
        instance_double(RepoProviderWebhookService, perform!: true)
      }

      context 'when the Repo does not exist' do
        it 'creates the Repo' do
          expect { do_the_thing }.to change { Repo.count }.by(1)
          expect(new_repo).to have_attributes(name: new_repo_attributes[:name])
        end
        it 'updates the webhook' do
          do_the_thing
          expect(RepoProviderWebhookService).to have_received(:new).with(new_repo)
        end
        it 'adds a RepoMembership for the current user' do
          do_the_thing
          expect(RepoMembership.last).to have_attributes(user: user, repo: new_repo)
        end
        it 'redirects to the friendly URL for the new repo' do
          do_the_thing
          expect(response).to redirect_to("/gh/#{repo_attributes[:name]}")
        end
      end
      context 'when the Repo already exists and is disabled' do
        let!(:existing_repo) {
          FactoryGirl.create(:github_repo, new_repo_attributes.merge(enabled: false))
        }

        it 'does not create the Repo' do
          expect { do_the_thing }.to_not change { Repo.count }
        end
        it 'enables the repo' do
          expect { do_the_thing; existing_repo.reload }.to change { existing_repo.enabled }
          expect(existing_repo).to be_enabled
        end
        it 'updates the webhook for the new repo' do
          expect(RepoProviderWebhookService).to receive(:new).with(new_repo)
          do_the_thing
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
        it 'redirects to the friendly URL for the new repo' do
          do_the_thing
          expect(response).to redirect_to("/gh/#{repo_attributes[:name]}")
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
    let!(:repo) { FactoryGirl.create(:github_repo) }

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

  describe 'GET /gh/:owner/:repo' do
    let(:do_the_thing) { get "/gh/#{repo.owner_name}/#{repo.repo_name}" }
    let!(:repo) { FactoryGirl.create(:github_repo) }

    context 'when logged in' do
      before(:each) do
        login_user user
      end
      context 'with the name of a repo that exists' do
        context 'that the user is a member of' do
          let!(:membership) { FactoryGirl.create(:repo_membership, repo: repo, user: user) }
          it 'shows the repo' do
            do_the_thing
            expect(response.body).to include(repo.name)
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
            it 'shows the repo' do
              do_the_thing
              expect(response.body).to include(repo.name)
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
    context 'without logging in' do
      it 'redirects to authentication' do
        expect(do_the_thing).to redirect_to(root_path)
      end
    end
  end

  describe 'GET /repos/:id/edit' do
    let(:do_the_thing) { get "/repos/#{repo.to_param}/edit" }
    let!(:repo) { FactoryGirl.create(:github_repo) }

    context 'when logged in' do
      before(:each) do
        login_user user
      end
      context 'with a repo that the user is an admin of' do
        let!(:membership) { FactoryGirl.create(:repo_membership, :admin, repo: repo, user: user) }
        it 'shows the repo settings' do
          do_the_thing
          expect(response.body).to include(repo.name)
          expect(response.body).to have_tag("input[type=checkbox]")
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

  describe 'PUT /repos/:id/update' do
    let(:do_the_thing) { put "/repos/#{repo.to_param}", params: { repo: repo_attributes } }
    let(:repo) { FactoryGirl.create(:github_repo) }
    let(:repo_attributes) { {} }

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

      context 'with a repo that the user is an admin of' do
        let!(:membership) { FactoryGirl.create(:repo_membership, :admin, repo: repo, user: user) }

        context 'disabling' do
          let(:repo_attributes) { { enabled: false } }

          it 'updates the repo' do
            do_the_thing
            repo.reload
            expect(repo).to_not be_enabled
          end
          it 'updates the webhook' do
            expect(RepoProviderWebhookService).to receive(:new).with(repo)
            do_the_thing
          end
          it 'redirects to the friendly URL for the repo' do
            do_the_thing
            expect(response).to redirect_to("/gh/#{repo.name}")
          end
        end
        context 'enabling' do
          let(:repo) { FactoryGirl.create(:github_repo, enabled: false) }
          let(:repo_attributes) { { enabled: true } }

          it 'updates the repo' do
            do_the_thing
            repo.reload
            expect(repo).to be_enabled
          end
          it 'updates the webhook' do
            expect(RepoProviderWebhookService).to receive(:new).with(repo)
            do_the_thing
          end
          it 'redirects to the friendly URL for the repo' do
            do_the_thing
            expect(response).to redirect_to("/gh/#{repo.name}")
          end
        end
        context 'changing nothing' do
          let(:repo) { FactoryGirl.create(:github_repo) }
          let(:repo_attributes) { { enabled: true } }

          it 'does not update the webhook' do
            expect(RepoProviderWebhookService).to_not receive(:new).with(repo)
            do_the_thing
          end
          it 'redirects to the friendly URL for the repo' do
            do_the_thing
            expect(response).to redirect_to("/gh/#{repo.name}")
          end
        end
      end
      context 'with a repo that the user is not a member of' do
        it 'responds with Access Denied' do
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
