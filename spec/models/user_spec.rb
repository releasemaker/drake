require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:user_identities) }
  it { is_expected.to have_many(:repo_memberships) }

  describe '#nickname' do
    let(:user) { FactoryGirl.create(:user) }
    let!(:user_identity) { FactoryGirl.create(:user_identity, user: user, nickname: 'abcd') }
    it 'returns the identity nickname' do
      expect(user.nickname).to eq(user_identity.nickname)
    end
  end

  describe '#email' do
    let(:user) { FactoryGirl.create(:user) }
    let!(:user_identity) { FactoryGirl.create(:user_identity, user: user, email: '123@e.com') }
    it 'returns the identity email' do
      expect(user.email).to eq(user_identity.email)
    end
  end
end
