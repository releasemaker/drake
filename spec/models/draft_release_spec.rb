require 'rails_helper'

RSpec.describe DraftRelease, vcr: { cassette_name: 'draft_release' } do
  subject(:instance) { described_class.new(repo: repo) }

  let(:repo) {
    FactoryGirl.create(
      :github_repo,
      provider_uid_or_url: Rails.configuration.x.github.test_repo_uid,
      name: "#{Rails.configuration.x.github.test_repo_owner_name}/#{repo_name}",
    )
  }
  let!(:user) { FactoryGirl.create(:user) }
  let!(:user_identity) {
    FactoryGirl.create(
      :user_identity,
      :github,
      user: user,
      token: Rails.configuration.x.github.test_auth_token,
    )
  }
  let!(:repo_membership) {
    FactoryGirl.create(:repo_membership, :admin, repo: repo, user: user)
  }
  let(:repo_name) { 'release-maker-tester-with-prior-release' }

  describe '.new' do
    context 'when a draft release does not exist' do
      let(:repo_name) { 'release-maker-tester-with-prior-release' }

      it 'sets up an empty body' do
        expect(instance).to have_attributes(
          body: "",
        )
      end
      it 'points to the master branch' do
        expect(instance).to have_attributes(
          target_commitish: "master",
        )
      end

      context 'when an existing release exists' do
        let(:repo_name) { 'release-maker-tester-with-prior-release' }

        it 'tags and names with the next version number by bumping the minor version' do
          expect(instance).to have_attributes(
            tag_name: 'v1.3.0',
            name: 'v1.3.0',
          )
        end
      end
      context 'when an existing release does not exist' do
        let(:repo_name) { 'release-maker-tester-no-releases' }

        it 'tags and names with a default version number of v0.1.0' do
          expect(instance).to have_attributes(
            tag_name: 'v0.1.0',
            name: 'v0.1.0',
          )
        end
      end
    end
    context 'when a draft release exists' do
      let(:repo_name) { 'release-maker-tester-with-draft-release' }

      it 'loads the existing release' do
        expect(instance).to have_attributes(
          tag_name: 'v2.3.4',
          name: 'v2.3.4',
          body: /This is a draft release, so new PRs will be appended to it/,
        )
      end
    end
  end

  describe '#append_to_body' do
    subject(:append_to_body) { instance.append_to_body(new_content) }
    let(:new_content) { "- New content" }

    context 'when the body is the default: one newline' do
      before do
        instance.body = "\r\n"
      end
      it 'appends the new content to the body, ending with a newline' do
        expect { append_to_body }.to change(instance, :body).
          to("- New content\r\n")
      end
    end
    context 'when the body ends with a newline' do
      before do
        instance.body = "- Existing content\r\n"
      end
      it 'appends the new content to the body, ending with a newline' do
        expect { append_to_body }.to change(instance, :body).
          to("- Existing content\r\n- New content\r\n")
      end
    end
    context 'when the body ends with multiple newlines' do
      before do
        instance.body = "- Existing content\r\n\r\n"
      end
      it 'collapses them into one and appends the new content to the body, ending with a newline' do
        expect { append_to_body }.to change(instance, :body).
          to("- Existing content\r\n- New content\r\n")
      end
    end
    context 'when the body does not end with a newline' do
      before do
        instance.body = "- Existing content"
      end
      it 'appends a newline and the new content to the body, ending with a newline' do
        expect { append_to_body }.to change(instance, :body).
          to("- Existing content\r\n- New content\r\n")
      end
    end
  end

  describe '#save' do
    subject(:save) { instance.save }
    context 'when the draft release already existed' do
      let(:repo_name) { 'release-maker-tester-with-draft-release' }

      it 'updates the existing release with the same id' do
        request = stub_request(
          :patch,
          %r{\Ahttps://api.github.com/repos/RobinDaugherty/release-maker-tester-with-draft-release/releases/\d+},
        )
        save
        expect(request).to have_been_made
      end
    end
    context 'when no draft release existed' do
      let(:repo_name) { 'release-maker-tester-no-releases' }

      it 'creates a new release' do
        request = stub_request(
          :post,
          %r{\Ahttps://api.github.com/repos/RobinDaugherty/release-maker-tester-no-releases/releases},
        )
        save
        expect(request).to have_been_made
      end
    end
  end
end
