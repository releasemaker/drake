# frozen_string_literal: true

# == Schema Information
#
# Table name: repo_memberships
#
#  id         :bigint           not null, primary key
#  admin      :boolean
#  write      :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  repo_id    :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_repo_memberships_on_repo_id              (repo_id)
#  index_repo_memberships_on_user_id              (user_id)
#  index_repo_memberships_on_user_id_and_repo_id  (user_id,repo_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe RepoMembership, type: :model do
  it { is_expected.to belong_to(:repo) }
  it { is_expected.to belong_to(:user) }
end
