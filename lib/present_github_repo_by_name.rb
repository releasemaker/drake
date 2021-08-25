# frozen_string_literal: true

##
# Responsible for finding a specific repo for a specific user.
# If the {GithubRepo} exists and the user has access, we return the record that exists.
# If the user does not have access, or if the {GithubRepo} does not exist, we
# look for the repo on Github. If found, we create the {GithubRepo} record if needed
# and grant the user access to it using the permissions that Github returned.
# @todo If the GithubRepo already exists but has a different name, update the existing record.
# @todo Treat the membership as a cache of permissions and have it expire after a period.
class PresentGithubRepoByName
  def initialize(owner_name:, repo_name:, user:)
    @owner_name = owner_name
    @repo_name = repo_name
    @user = user
  end

  def repo
    GithubRepo.transaction do
      unless user_has_access?
        # TODO: cache this data for the user and repository for a period of time.
        local_repo.repo_memberships.create!(
          user: user,
          admin: github_matching_repo.permissions.admin,
        )
      end
      local_repo
    end
  end

  private

  attr_reader :owner_name
  attr_reader :repo_name
  attr_reader :user

  def local_repo
    @local_repo ||= existing_local_repo || created_local_repo
  end

  def existing_local_repo
    GithubRepo.find_by(name: "#{owner_name}/#{repo_name}")
  end

  def created_local_repo
    GithubRepo.new_from_api(github_matching_repo).tap do |repo|
      repo.enabled = false
      repo.save!
    end
  end

  def github_matching_repo
    @github_matching_repo ||= user.github_client.repos.get(owner_name, repo_name)
  end

  def user_has_access?
    local_repo.repo_memberships.find_by(user: user)
  end
end
