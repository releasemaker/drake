# Connection of a {User} to a specific account at an authentication provider.
# @todo When a record is deleted, remove {RepoMembership} records that belong to the user
#   if they are based on this identity.
class UserIdentity < ActiveRecord::Base
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
