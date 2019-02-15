require 'rails_helper'

RSpec.describe Api::AvailableReposController, type: :request do
  let(:user) { FactoryGirl.create(:user, :with_credentials) }

  describe 'GET /api/availableRepos' do
    let(:do_the_thing) { get '/api/availableRepos', params: params }
    let(:params) { {} }

    it_behaves_like :authenticated_endpoint

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
      let(:json_body) { JSON.parse(response.body) }

      context 'without a search term' do
        it 'responds with OK' do
          do_the_thing
          expect(response).to have_http_status(:ok)
        end

        it 'responds with JSON containing availableRepos' do
          do_the_thing
          expect(json_body).to include('availableRepos')
        end

        it 'lists each repository' do
          do_the_thing
          expect(json_body['availableRepos']).to match_array([
            include(
              'isEnabled' => false,
              'repoType' => 'gh',
              'providerUid' => '1296269',
              'name' => 'octocat/Hello-World',
              'path' => '/gh/octocat/Hello-World',
            ),
            include(
              'isEnabled' => false,
              'repoType' => 'gh',
              'providerUid' => '1296270',
              'name' => 'octocat/Goodbye-World',
              'path' => '/gh/octocat/Goodbye-World',
            ),
          ])
        end

        context 'when the user does not have admin access to the repo' do
          it 'includes that in the repo information'
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

            it 'includes the persisted repo with isEnabled false' do
              do_the_thing
              expect(json_body['availableRepos'].find { |r| r['providerUid'] == "1296269" }).to include(
                'isEnabled' => false,
              )
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

            it 'includes the persisted repo with isEnabled true' do
              do_the_thing
              expect(json_body['availableRepos'].find { |r| r['providerUid'] == "1296269" }).to include(
                'isEnabled' => true,
              )
            end
          end
        end
      end

      context 'with a search term' do
        before do
          skip
        end

        let(:params) { { q: search_term } }

        context 'that matches a repo' do
          let(:search_term) { "Hello" }

          it 'includes a list of matching repositories with Enable buttons' do
            do_the_thing
            expect(response.body).to have_tag('tr[data-provider-uid="1296269"]') do
              with_tag('td', 'octocat/Hello-World')
              with_button('Enable')
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

              it 'shows the persisted repo with an Enable button' do
                do_the_thing
                expect(response.body).to have_tag('tr[data-provider-uid="1296269"]') do
                  with_tag('td', 'octocat/Hello-World')
                  with_button('Enable')
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

              it 'shows the persisted repo with an Enable button' do
                do_the_thing
                expect(response.body).to have_tag('tr[data-provider-uid="1296269"]') do
                  with_tag('td', 'octocat/Hello-World')
                  with_tag('a', 'Enabled')
                  without_button('Enable')
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
  end
end
