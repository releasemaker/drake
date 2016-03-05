require 'rails_helper'

RSpec.describe GithubRepo, type: :model do
  it { expect(described_class).to be < Repo }

  context 'a user' do
    subject(:ability) { Ability.new(user) }
    let(:user) { FactoryGirl.create(:user) }
    let(:repo) { FactoryGirl.create(described_class) }

    it { is_expected.to be_able_to(:create, described_class) }

    it { is_expected.to_not be_able_to(:read, repo) }
    it { is_expected.to_not be_able_to(:update, repo) }
    it { is_expected.to_not be_able_to(:delete, repo) }

    context 'that is a member of the repo' do
      let!(:repo_membership) {
        FactoryGirl.create(:repo_membership, repo: repo, user: user)
      }

      it { is_expected.to be_able_to(:read, repo) }
      it { is_expected.to_not be_able_to(:update, repo) }
      it { is_expected.to_not be_able_to(:delete, repo) }

      context 'and is an admin' do
        let!(:repo_membership) {
          FactoryGirl.create(:repo_membership, :admin, repo: repo, user: user)
        }

        it { is_expected.to be_able_to(:update, repo) }
        it { is_expected.to be_able_to(:delete, repo) }
      end
    end

    context 'that is a super admin' do
      let(:user) { FactoryGirl.create(:user, :super_admin) }

      it { is_expected.to be_able_to(:read, repo) }
      it { is_expected.to be_able_to(:update, repo) }
      it { is_expected.to be_able_to(:delete, repo) }
    end
  end
end
