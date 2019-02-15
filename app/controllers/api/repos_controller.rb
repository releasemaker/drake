class Api::ReposController < ApplicationController
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
