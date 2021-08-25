# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubRepo, type: :model do
  it { expect(described_class).to be < Repo }

  describe '::new_from_api' do
    subject { described_class.new_from_api(repository) }
    let(:api_data) { json_fixture('github/repositories') }
    let!(:api_request) {
      stub_request(:get, "https://api.github.com/user/repos?access_token=#{access_token}")
        .to_return(body: api_data, status: 200)
    }
    let(:access_token) { "12345" }
    let(:github_client) { Github.new(oauth_token: access_token) }

    context 'with one repo from a list of repositories' do
      let(:repository) { github_client.repositories.list.first }

      it { is_expected.to be_kind_of(described_class) }
      it 'assigns the name from the API' do
        expect(subject.name).to eq("octocat/Hello-World")
      end
      it 'assigns data the API response' do
        expect(subject.provider_data.name).to eq("Hello-World")
        expect(subject.provider_data.fork).to be_truthy
        expect(subject.provider_data.owner.login).to eq("octocat")
      end
    end

    context 'with one repo from a direct lookup', vcr: {cassette_name: 'github_repo'} do
      let(:access_token) { Rails.configuration.x.github.test_auth_token }
      let(:repository) {
        github_client.repositories.get(owner_name, repo_name)
      }
      let(:owner_name) { Rails.configuration.x.github.test_repo_owner_name }
      let(:repo_name) { Rails.configuration.x.github.test_repo_name }

      it { is_expected.to be_kind_of(described_class) }
      it 'assigns the name from the API' do
        expect(subject.name).to eq("#{owner_name}/#{repo_name}")
      end
      it 'assigns data the API response' do
        expect(subject.provider_data.name).to eq(repo_name)
        expect(subject.provider_data.fork).to be_falsey
        expect(subject.provider_data.owner.login).to eq(owner_name)
      end
    end
  end
end
