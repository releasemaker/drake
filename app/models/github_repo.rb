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
# A {Repo} record that is associated with a Github repository.
class GithubRepo < Repo
  def self.new_from_api(data)
    new do |repo|
      repo.name = data.full_name
      repo.provider_uid_or_url = data.id
      repo.provider_data = data.to_h
    end
  end

  def owner_name
    name.split('/').first
  end

  def repo_name
    name.split('/').last
  end

  delegate :github_client, to: :admin_user

  ##
  # Used as the first part of the friendly URL for a repo, and identifies the type in the API.
  def short_type
    'gh'
  end

  def friendly_path
    "/#{short_type}/#{name}"
  end
end
