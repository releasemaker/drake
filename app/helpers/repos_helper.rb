module ReposHelper
  # The existing {Repo} records that the user has access to, paginated.
  def repos
    @repos #.page(page).per_page(per_page)
  end

  # The paginated API request that is returning repositories.
  # This object will be paginated using Kaminari, so it must respond to the various methods
  # that expects.
  def available_repos_response
    @available_repos_response ||= current_user.github_client.
      repositories.
      all(page: page, per_page: per_page)
  end

  # A list of unpersisted {Repo} records representing repositories that the user has access
  # to and can turn into a persisted {Repo}.
  # @todo Augment with repos that already exist as {Repo} records.
  def available_repos
    @available_repos ||= available_repos_response.
      map { |data| GithubRepo.new_from_api(data) }
  end
end
