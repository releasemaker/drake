# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identities
#
#  id         :bigint           not null, primary key
#  data       :json
#  provider   :string
#  uid        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_user_identities_on_provider_and_uid      (provider,uid) UNIQUE
#  index_user_identities_on_user_id               (user_id)
#  index_user_identities_on_user_id_and_provider  (user_id,provider) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
# Connection of a {User} to a specific account at an authentication provider.
# @todo When a record is deleted, remove {RepoMembership} records that belong to the user
#   if they are based on this identity.
class UserIdentity < ApplicationRecord
  belongs_to :user

  def nickname
    data['info']['nickname']
  end

  def email
    data['info']['email']
  end

  def token
    data.try(:[], 'credentials').try(:[], 'token')
  end
end
