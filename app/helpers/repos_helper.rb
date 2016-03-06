module ReposHelper
  def repos
    @repos #.page(page).per_page(per_page)
  end

  def available_repos_response
    @available_repos_response ||= current_user.github_client.
      repositories.
      all(page: page, per_page: per_page)
  end

  def available_repos
    @available_repos ||= available_repos_response.
      map { |data| GithubRepo.new_from_api(data) }
  end

  def page
    params[:page] || 1
  end

  def per_page
    params[:per_page] || 25
  end
end
