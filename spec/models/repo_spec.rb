require 'rails_helper'

RSpec.describe Repo, type: :model do
  it { is_expected.to have_many(:repo_memberships) }
  it { is_expected.to validate_uniqueness_of(:provider_uid_or_url).scoped_to(:type) }

  it { is_expected.to serialize(:provider_data) }
  describe '#provider_data=' do
    before do
      subject.provider_data = new_data
    end
    let(:new_data) { { "stuff" => "thing" } }
    it 'converts the assigned value' do
      expect(subject.provider_data).to have_attributes(stuff: "thing")
    end
  end

  it { is_expected.to serialize(:provider_webhook_data) }
  describe '#provider_webhook_data=' do
    before do
      subject.provider_webhook_data = new_data
    end
    let(:new_data) { { "stuff" => "thing" } }
    it 'converts the assigned value' do
      expect(subject.provider_webhook_data).to have_attributes(stuff: "thing")
    end
  end

  describe '#admin_user' do
    context 'with a read-only member' do
      let!(:read_membership) { FactoryBot.create(:repo_membership, repo: subject) }
      it 'returns nil' do
        expect(subject.admin_user).to be_nil
      end
      context 'and an admin member' do
        let!(:admin_membership) { FactoryBot.create(:repo_membership, :admin, repo: subject) }
        it 'returns the admin user' do
          expect(subject.admin_user).to eq(admin_membership.user)
        end
      end
    end
  end

  context 'a user' do
    subject(:ability) { Ability.new(user) }
    let(:user) { FactoryBot.create(:user) }
    let(:repo) { FactoryBot.create(described_class) }

    it { is_expected.to be_able_to(:create, described_class) }

    it { is_expected.to_not be_able_to(:read, repo) }
    it { is_expected.to_not be_able_to(:update, repo) }
    it { is_expected.to_not be_able_to(:delete, repo) }

    context 'that is a member of the repo' do
      let!(:repo_membership) {
        FactoryBot.create(:repo_membership, repo: repo, user: user)
      }

      it { is_expected.to be_able_to(:read, repo) }
      it { is_expected.to_not be_able_to(:update, repo) }
      it { is_expected.to_not be_able_to(:delete, repo) }

      context 'and is an admin' do
        let!(:repo_membership) {
          FactoryBot.create(:repo_membership, :admin, repo: repo, user: user)
        }

        it { is_expected.to be_able_to(:update, repo) }
        it { is_expected.to be_able_to(:delete, repo) }
      end
    end

    context 'that is a super admin' do
      let(:user) { FactoryBot.create(:user, :super_admin) }

      it { is_expected.to be_able_to(:read, repo) }
      it { is_expected.to be_able_to(:update, repo) }
      it { is_expected.to be_able_to(:delete, repo) }
    end
  end
end
