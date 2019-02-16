require 'rails_helper'

RSpec.describe PullRequestHandler do
  describe '#handle!' do
    subject(:instance) { described_class.new(hook_payload: hook_payload) }
    before do
      allow(DraftRelease).to receive(:new).and_return(draft_release)
      allow(draft_release).to receive_message_chain('append_to_body.save')
    end
    let(:draft_release) { instance_double(DraftRelease) }
    let(:repo) {
      FactoryBot.create(
        :github_repo,
        provider_uid_or_url: Rails.configuration.x.github.test_repo_uid,
        name: "#{Rails.configuration.x.github.test_repo_owner_name}/#{repo_name}",
      )
    }
    let(:repo_name) { 'release-maker-tester-no-releases' }

    context 'when the pull request was closed and merged' do
      let(:hook_payload) { parsed_json_fixture('github/hooks/merged_pull_request') }

      context 'and it was merged into master' do
        it 'creates a DraftRelease and calls append_to_body' do
          expect(DraftRelease).to receive(:new).with(
            repo: repo,
          )
          expect(draft_release).to receive(:append_to_body)
            .with('- Update README.md and do amazing stuff #1')
            .and_return(draft_release)
          expect(draft_release).to receive(:save)
          instance.handle!
        end
      end
      context 'and it was merged into a branch other than the default branch' do
        before do
          hook_payload["pull_request"]["base"]["ref"] = "other_branch"
        end

        it 'does not create a DraftRelease' do
          expect(DraftRelease).to_not receive(:new)
          instance.handle!
        end
      end
    end
    context 'when the pull request was closed without merging' do
      let(:hook_payload) { parsed_json_fixture('github/hooks/closed_pull_request') }

      it 'does not create a DraftRelease' do
        expect(DraftRelease).to_not receive(:new)
        instance.handle!
      end
    end
    context 'when the pull request was opened' do
      let(:hook_payload) { parsed_json_fixture('github/hooks/new_pull_request') }

      it 'does not create a DraftRelease' do
        expect(DraftRelease).to_not receive(:new)
        instance.handle!
      end
    end
  end
end
