require 'rails_helper'

RSpec.describe RepoProviderWebhookService do
  subject(:instance) { described_class.new(repo) }

  before do
    Rails.configuration.x.webhooks.host = 'release-maker.test'
    Rails.configuration.x.webhooks.secret = 'abcd12345'
  end

  describe '#perform!' do
    let(:do_the_thing) { subject.perform! }

    let(:repo) {
      FactoryBot.create(
        :github_repo,
        provider_uid_or_url: Rails.configuration.x.github.test_repo_uid,
        name: "#{Rails.configuration.x.github.test_repo_owner_name}/"\
          "#{Rails.configuration.x.github.test_repo_name}",
        enabled: repo_enabled,
        provider_webhook_data: repo_provider_webhook_data,
      )
    }

    context 'making API calls', vcr: { cassette_name: 'webhook_service' } do
      let(:repo_provider_webhook_data) { nil }
      let(:repo_enabled) { true }
      let!(:user) { FactoryBot.create(:user) }
      let!(:user_identity) {
        FactoryBot.create(
          :user_identity,
          :github,
          user: user,
          token: Rails.configuration.x.github.test_auth_token,
        )
      }
      let!(:repo_membership) {
        FactoryBot.create(:repo_membership, :admin, repo: repo, user: user)
      }

      it 'stores the created webhook data and uses it to remove the webhook' do
        expect(repo.provider_webhook_data).to be_empty
        described_class.new(repo).perform!
        expect(repo.provider_webhook_data).to_not be_empty
        repo.update! enabled: false
        described_class.new(repo).perform!
        expect(repo.provider_webhook_data).to be_empty
      end
    end

    context 'testing just the behavior' do
      before do
        allow(repo).to receive_message_chain('github_client.repos.hooks').and_return(hooks_api)
      end
      let(:hooks_api) { double('hooks_api', create: true, delete: true) }

      context 'with a github repo that is enabled' do
        let(:repo_enabled) { true }

        context 'when provider_webhook_data is empty' do
          let(:repo_provider_webhook_data) { nil }
          before do
            allow(hooks_api).to receive(:create).and_return(id: 42)
          end

          it 'adds a github webhook' do
            expect(hooks_api).to receive(:create)
            do_the_thing
          end
          it 'updates provider_webhook_data' do
            do_the_thing
            repo.reload
            expect(repo.provider_webhook_data.id).to eq(42)
          end
        end
        context 'when provider_webhook_data is set' do
          let(:repo_provider_webhook_data) { { id: 42 } }
          it 'does not call github' do
            expect(hooks_api).to_not receive(:create)
            expect(hooks_api).to_not receive(:delete)
            do_the_thing
          end
        end
      end

      context 'with a github repo that is disabled' do
        let(:repo_enabled) { false }

        context 'when provider_webhook_data is empty' do
          let(:repo_provider_webhook_data) { nil }
          it 'does not call github' do
            expect(hooks_api).to_not receive(:create)
            expect(hooks_api).to_not receive(:delete)
            do_the_thing
          end
        end

        context 'when provider_webhook_data is set' do
          let(:repo_provider_webhook_data) { { id: 42 } }

          it 'removes the github webhook' do
            expect(hooks_api).to receive(:delete).with(repo.owner_name, repo.repo_name, 42)
            do_the_thing
          end

          it 'updates provider_webhook_data' do
            do_the_thing
            repo.reload
            expect(repo.provider_webhook_data).to be_empty
          end

          context 'when github raises NotFound when trying to remove the webhook' do
            let(:fake_response) {
              {
                response_headers: [],
                body: '',
                status: 404,
                method: 'GET',
                url: '/test',
              }
            }
            before do
              allow(hooks_api).to receive(:delete).and_raise(Github::Error::NotFound, fake_response)
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
  end
end
