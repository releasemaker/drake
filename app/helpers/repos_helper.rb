module ReposHelper
  def repos
    @repos #.page(page).per_page(per_page)
  end

  def available_repos
    @available_repos ||= current_user.github_client.
      repositories.
      list. #.all(page: page, per_page: per_page)
      map { |data| GithubRepo.new_from_api(data) }
  end

  def page
    params[:p] || 1
  end

  def per_page
    params[:rpp] || 25
  end
end
