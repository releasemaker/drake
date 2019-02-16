# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PresentGithubRepoByName do
  let(:instance) { described_class.new(owner_name: owner_name, repo_name: repo_name, user: user) }

  describe '#repo' do
    subject(:repo) { instance.repo }
    let(:owner_name) { "octocat" }
    let(:repo_name) { "Hello-World" }
    let(:user) { FactoryBot.create(:user, :with_credentials) }
    let!(:user_github_identity) { FactoryBot.create(:user_identity, :github, user: user) }

    let(:api_data) { json_fixture('github/repository_admin') }
    let!(:api_request) {
      stub_request(:get, %r{https://api\.github\.com/repos/octocat/Hello-World\?access_token=.+})
        .to_return(body: api_data, status: 200)
    }

    context 'when a GithubRepo record already exists' do
      let!(:existing_repo) {
        FactoryBot.create(:github_repo, name: 'octocat/Hello-World', enabled: false)
      }

      it 'returns the GithubRepo object' do
        expect(repo).to eq(existing_repo)
      end

      it 'does not create another Repo record' do
        expect { repo }.to_not change(Repo, :count)
      end

      context 'when the user already has a RepoMembership for this repo' do
        let!(:existing_repo_membership) {
          FactoryBot.create(:repo_membership, user: user, repo: existing_repo)
        }

        it 'does not fetch the repository information from Github' do
          repo
          expect(api_request).not_to have_been_made
        end

        it 'remains' do
          expect { repo }.not_to change { existing_repo_membership.reload.updated_at }
        end
      end

      context 'when the user does not have a RepoMembership for this repo' do
        it 'fetches the repository information from Github' do
          repo
          expect(api_request).to have_been_made
        end

        context 'when Github says the current user is an admin on this repo' do
          it 'adds a RepoMembership for the current user with admin set' do
            repo
            expect(RepoMembership.last).to have_attributes(
              user: user,
              repo: existing_repo,
              admin: true,
            )
          end
        end

        context 'when Github says the current user is not an admin on this repo' do
          let(:api_data) { json_fixture('github/repository_not_admin') }

          it 'adds a RepoMembership for the current user with admin not set' do
            repo
            expect(RepoMembership.last).to have_attributes(
              user: user,
              repo: existing_repo,
              admin: false,
            )
          end
        end
      end
    end

    context 'when a GithubRepo object does not already exist' do
      let(:created_repo) { GithubRepo.find_by(name: 'octocat/Hello-World') }

      it 'fetches the repository information from Github' do
        repo
        expect(api_request).to have_been_made
      end

      it 'creates a new GithubRepo record' do
        expect { repo }.to change(Repo, :count).by(1)
        expect(created_repo).to have_attributes(name: 'octocat/Hello-World')
      end

      it 'returns the new GithubRepo object' do
        expect(repo).to eq(created_repo)
      end

      context 'when Github says the current user is an admin on this repo' do
        it 'adds a RepoMembership for the current user with admin set' do
          repo
          expect(RepoMembership.last).to have_attributes(
            user: user,
            repo: created_repo,
            admin: true,
          )
        end
      end

      context 'when Github says the current user is not an admin on this repo' do
        let(:api_data) { json_fixture('github/repository_not_admin') }

        it 'adds a RepoMembership for the current user with admin not set' do
          repo
          expect(RepoMembership.last).to have_attributes(
            user: user,
            repo: created_repo,
            admin: false,
          )
        end
      end
    end
  end
end
