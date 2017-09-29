module ApplicationHelper
  def github_auth_path
    '/auth/github'
  end

  def friendly_repo_url(repo)
    if repo.respond_to?(:owner_name) && repo.respond_to?(:repo_name)
      github_repo_by_name_url(repo.owner_name, repo.repo_name)
    else
      repo_url(repo)
    end
  end

  def friendly_repo_path(repo)
    if repo.respond_to?(:owner_name) && repo.respond_to?(:repo_name)
      github_repo_by_name_path(repo.owner_name, repo.repo_name)
    else
      repo_path(repo)
    end
  end
end
