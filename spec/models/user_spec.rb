# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id               :bigint           not null, primary key
#  crypted_password :string
#  email            :string
#  name             :string
#  salt             :string
#  super_admin      :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:user_identities) }
  it { is_expected.to have_many(:repo_memberships) }
  it { is_expected.to have_many(:repos).through(:repo_memberships) }

  describe '#nickname' do
    let(:user) { FactoryBot.create(:user) }
    let!(:user_identity) { FactoryBot.create(:user_identity, user: user, nickname: 'abcd') }
    it 'returns the identity nickname' do
      user.user_identities.reload
      expect(user.nickname).to eq(user_identity.nickname)
    end
  end

  describe '#email' do
    let(:user) { FactoryBot.create(:user) }
    let!(:user_identity) { FactoryBot.create(:user_identity, user: user, email: '123@e.com') }
    it 'returns the identity email' do
      user.user_identities.reload
      expect(user.email).to eq(user_identity.email)
    end
  end
end
