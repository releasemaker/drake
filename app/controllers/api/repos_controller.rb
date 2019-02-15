class Api::ReposController < ApplicationController
  include PaginationHelper

  def index
    authorize! :index, Repo
    @repos = current_user.repos.page(page).per(per_page)
    @paginated_content = @repos
  end

  def show
    @repo = PresentGithubRepoByName.new(
      owner_name: params[:owner],
      repo_name: params[:repo],
      user: current_user,
    ).repo
    authorize! :show, @repo
  rescue Github::Error::NotFound
    raise ActionController::RoutingError.new('Not Found')
  end
end
