# Shows the user their list of {Repo}s, allows them to edit their settings for a {Repo},
# enumerates available repos on SCM providers and allows them to
# create a {Repo} record for it.
class ReposController < ApplicationController
  load_and_authorize_resource :repo, except: [:create, :show_by_name]
  include PaginationHelper
  include ApplicationHelper

  skip_load_resource only: %i(index)
  # Lists the current user's {Repo}s.
  def index
    @repos = current_user.repos.page(page).per(per_page)
  end

  # Lists the available repositories on available SCM providers, and provides a form
  # for each that points to the {#create} action.
  def new
    # The paginated API request that is returning repositories.
    # This object will be paginated using Kaminari, so it must respond to the various methods
    # that Kaminari expects.
    if params[:q].present?
      all_repos = Rails.cache.fetch(
        "github_all_repos/for_user/#{current_user.nickname}",
        expires_in: 5.minutes,
      ) do
        current_user.github_client.
          repositories.
          list(auto_pagination: true)
      end
      @available_repos = repo_list_from_response(
        all_repos.select { |repo| repo.full_name.downcase.include? params[:q].downcase },
      )
    else
      @available_repos_response = current_user.github_client.
          repositories.
          all(page: page, per_page: per_page)

      @available_repos = repo_list_from_response @available_repos_response
    end
  end

  # Creates a {Repo} record based on the form submission from the {#new} view.
  # There is an assumption that this will succeed, since there is no user-editable form.
  # @todo Use the permissions given by Github instead of assuming admin.
  def create
    Repo.transaction do
      existing_repo = GithubRepo.find_by(provider_uid_or_url: create_params[:provider_uid_or_url])
      @repo = existing_repo || GithubRepo.new(create_params)
      @repo.enabled = true
      @repo.save!

      unless @repo.repo_memberships.find_by(user: current_user)
        @repo.repo_memberships.create!(user: current_user, admin: true)
      end

      RepoProviderWebhookService.new(@repo).perform!
    end

    authorize! :create, @repo
    redirect_to friendly_repo_url(@repo)
  end

  # Redirects to the correct route for the repo
  def show
    redirect_to friendly_repo_url @repo
  end

  def show_by_name
    @repo = PresentGithubRepoByName.new(
      owner_name: params[:owner],
      repo_name: params[:repo],
      user: current_user,
    ).repo
    authorize! :show, @repo
    render :show
  rescue Github::Error::NotFound
    raise ActionController::RoutingError.new('Not Found')
  end

  def update
    Repo.transaction do
      @repo.assign_attributes(update_params)
      need_to_update_webhook = @repo.enabled_changed?
      if @repo.save
        RepoProviderWebhookService.new(@repo).perform! if need_to_update_webhook

        flash[:notice] = "Settings saved."
        redirect_to friendly_repo_url(@repo)
      else
        flash[:alert] = "There was a problem saving your changes."
        render :show
      end
    end
  end

  private

  def create_params
    params.require(:repo).permit(:type, :name, :provider_uid_or_url)
  end

  def update_params
    params.require(:repo).permit(:enabled)
  end

  # Array of {Repo}s that match those in the response. Some may be persisted.
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
      matching_existing_repos.find { |r|
        r.type == available_repo.type && r.provider_uid_or_url == available_repo.provider_uid_or_url
      } || available_repo
    }
  end
end
