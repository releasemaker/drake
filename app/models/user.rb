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
