# A person who can log in to the application.
class User < ActiveRecord::Base
  include Concerns::User::GithubAccount

  authenticates_with_sorcery!
  has_many :user_identities
  has_many :repo_memberships
  has_many :repos, through: :repo_memberships

  validates :email, uniqueness: true, allow_nil: true

  def nickname
    user_identities.find(&:nickname).try(:nickname)
  end

  def email
    super || user_identities.find(&:email).try(:email)
  end
end
