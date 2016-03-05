class User < ActiveRecord::Base
  authenticates_with_sorcery!
  has_many :user_identities
  has_many :repo_memberships

  def nickname
    user_identities.find(&:nickname).try(:nickname)
  end

  def email
    user_identities.find(&:email).try(:email)
  end
end
