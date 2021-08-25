# frozen_string_literal: true

# == Schema Information
#
# Table name: repos
#
#  id                    :bigint           not null, primary key
#  enabled               :boolean
#  name                  :string
#  provider_data         :json
#  provider_uid_or_url   :string
#  provider_webhook_data :json
#  type                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_repos_on_type_and_provider_uid_or_url  (type,provider_uid_or_url) UNIQUE
#
# Base repository object used for single-table inheritance by Repo classes used for different
# SVM providers.
class Repo < ApplicationRecord
  has_many :repo_memberships, dependent: :destroy

  validates :provider_uid_or_url, uniqueness: {scope: :type}

  serialize :provider_data, Hashie::Mash

  # This allows the field to be set as a Hash or anything compatible with it.
  def provider_data=(new_value)
    self[:provider_data] = Hashie::Mash.new new_value
  end

  serialize :provider_webhook_data, Hashie::Mash

  # This allows the field to be set as a Hash or anything compatible with it.
  def provider_webhook_data=(new_value)
    self[:provider_webhook_data] = Hashie::Mash.new new_value
  end

  # A user whose API token will be used for this repo.
  def admin_user
    @admin_user ||= repo_memberships.joins(:user).includes(:user).find_by(admin: true).try(:user)
  end
end
