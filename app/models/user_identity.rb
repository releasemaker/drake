# frozen_string_literal: true

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
