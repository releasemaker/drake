class Api::AvailableReposController < ApplicationController
  authorize_resource :repo
  include PaginationHelper

  def index
    github_repos = current_user.github_client.
      repositories.
      all(page: page, per_page: per_page)

    @paginated_content = github_repos
    @available_repos = repo_list_from_response github_repos
  end

  private

  # Array of {Repo}s that match those in the response. Some may be persisted Repo records.
  def repo_list_from_response(response)
    # Unpersisted {Repo} records representing repositories in the response.
    # The response just needs to support Enumerable.
    matching_repos = response.
      map { |data| GithubRepo.new_from_api(data) }

    # Any existing {Repo} objects that match the list of available repositories being shown.
    matching_existing_repos = matching_repos.map(&:type).uniq.map { |repo_class|
      uids = matching_repos.select { |r| r.type == repo_class }.map(&:provider_uid_or_url)
      repo_class.constantize.where(provider_uid_or_url: uids).all
    }.flatten

    matching_repos.map { |available_repo|
      persisted_repo = matching_existing_repos.find { |r|
        r.type == available_repo.type && r.provider_uid_or_url == available_repo.provider_uid_or_url
      }
      persisted_repo || available_repo
    }
  end
end
