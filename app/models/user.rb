# frozen_string_literal: true

# A person who can log in to the application.
class User < ApplicationRecord
  include HasGithubAccount

  authenticates_with_sorcery!
  has_many :user_identities, dependent: :destroy
  has_many :repo_memberships, dependent: :destroy
  has_many :repos, through: :repo_memberships

  validates :email, uniqueness: true, allow_nil: true

  def nickname
    user_identities.find(&:nickname).try(:nickname)
  end

  def email
    super || user_identities.find(&:email).try(:email)
  end
end
