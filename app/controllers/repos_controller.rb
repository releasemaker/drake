# Shows the user their list of {Repo}s, allows them to edit their settings for a {Repo},
# enumerates available repos on SCM providers and allows them to
# create a {Repo} record for it.
class ReposController < ApplicationController
  load_and_authorize_resource :repo
  include PaginationHelper

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
    # that expects.
    @available_repos_response = current_user.github_client.
        repositories.
        all(page: page, per_page: per_page)

    # Unpersisted {Repo} records representing repositories in the response.
    # The response just needs to support Enumerable.
    # @todo Augment with repos that already exist as {Repo} records.
    matching_repos = @available_repos_response.
      map { |data| GithubRepo.new_from_api(data) }

    # Any existing {Repo} objects that match the list of available repositories being shown.
    matching_existing_repos = matching_repos.map(&:type).uniq.map { |repo_class|
      uids = matching_repos.select { |r| r.type == repo_class }.map(&:provider_uid_or_url)
      repo_class.constantize.where(provider_uid_or_url: uids).all
    }.flatten

    # {Repo}s that match the current search. Some may be persisted.
    @available_repos = matching_repos.map { |available_repo|
      matching_existing_repos.find { |r|
        r.type == available_repo.type && r.provider_uid_or_url == available_repo.provider_uid_or_url
      } || available_repo
    }
  end

  # Creates a {Repo} record based on the form submission from the {#new} view.
  # There is an assumption that this will succeed, since there is no user-editable form.
  # @todo Use the permissions given by Github instead of assuming admin.
  def create
    existing_repo = Repo.find_by(type: @repo.type, provider_uid_or_url: @repo.provider_uid_or_url)
    @repo = existing_repo if existing_repo
    @repo.enabled = true
    @repo.save!

    unless @repo.repo_memberships.find_by(user: current_user)
      @repo.repo_memberships.create!(user: current_user, admin: true)
    end

    redirect_to @repo
  end

  # Shows the repository to the user.
  # @todo If the user doesn't currently have a {RepoMembership} in the repository, check the SCM
  #   to see if they have permission, and create that {RepoMembership} record.
  def show
    
  end

  def update
    if @repo.update_attributes(update_params)
      flash[:notice] = "Settings saved."
      redirect_to action: :edit
    else
      render :show
    end
  end

  private

  def create_params
    params.require(:repo).permit(:type, :name, :provider_uid_or_url)
  end

  def update_params
    params.require(:repo).permit(:enabled)
  end
end
