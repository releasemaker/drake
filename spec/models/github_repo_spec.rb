require 'rails_helper'

RSpec.describe GithubRepo, type: :model do
  it { expect(described_class).to be < Repo }

  describe '::new_from_api' do
    subject { described_class.new_from_api(repository) }
    let(:api_data) { json_fixture('github/repositories') }
    let!(:api_request) {
      stub_request(:get, "https://api.github.com/user/repos?access_token=12345")
        .to_return(body: api_data, status: 200)
    }
    let(:github_client) { Github.new(oauth_token: '12345') }
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
end
