require 'rails_helper'

RSpec.describe RepoProviderWebhookService do
  subject { described_class.new(repo) }

  before do
    allow(repo).to receive_message_chain('github_client.repos.hooks').and_return(api_endpoint)
    Rails.configuration.x.webhooks.host = 'goldi.test'
    Rails.configuration.x.webhooks.secret = 'abcd12345'
  end
  let(:api_endpoint) { double('api_endpoint', create: true, delete: true) }

  describe '#perform!' do
    let(:do_the_thing) { subject.perform! }
    let(:repo) {
      FactoryGirl.create(
        :github_repo,
        enabled: repo_enabled,
        provider_webhook_data: provider_webhook_data,
      )
    }

    context 'with a github repo that is enabled' do
      let(:repo_enabled) { true }

      context 'when provider webhook data is empty' do
        let(:provider_webhook_data) { nil }
        before do
          allow(api_endpoint).to receive(:create).and_return(Hashie::Mash.new(id: 42))
        end

        it 'adds a github webhook' do
          expect(api_endpoint).to receive(:create)
          do_the_thing
        end
        it 'updates provider_webhook_data' do
          do_the_thing
          repo.reload
          expect(repo.provider_webhook_data.id).to eq(42)
        end
      end
      context 'when provider webhook data is set' do
        let(:provider_webhook_data) { { id: 42 } }
        it 'does not call github' do
          expect(api_endpoint).to_not receive(:create)
          expect(api_endpoint).to_not receive(:delete)
          do_the_thing
        end
      end
    end
    context 'with a github repo that is disabled' do
      let(:repo_enabled) { false }

      context 'when provider webhook data is empty' do
        let(:provider_webhook_data) { nil }
        it 'does not call github' do
          expect(api_endpoint).to_not receive(:create)
          expect(api_endpoint).to_not receive(:delete)
          do_the_thing
        end
      end
      context 'when provider webhook data is set' do
        let(:provider_webhook_data) { { id: 42 } }
        it 'removes the github webhook' do
          expect(api_endpoint).to receive(:delete).with(repo.owner_name, repo.repo_name, 42)
          do_the_thing
        end
        it 'updates provider_webhook_data' do
          do_the_thing
          repo.reload
          expect(repo.provider_webhook_data).to be_empty
        end
      end
    end
  end
end
