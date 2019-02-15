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

  # Creates a {Repo} record based on the form submission from the {#new} view.
  # There is an assumption that this will succeed, since there is no user-editable form.
  # @todo Use the permissions given by Github instead of assuming admin.
  def create
    Repo.transaction do
      existing_repo = create_repo_class.find_by(provider_uid_or_url: create_params[:provider_uid_or_url])
      @repo = existing_repo || create_repo_class.new(create_params)
      @repo.enabled = true
      @repo.save!

      unless @repo.repo_memberships.find_by(user: current_user)
        @repo.repo_memberships.create!(user: current_user, admin: true)
      end

      RepoProviderWebhookService.new(@repo).perform!
    end

    authorize! :create, @repo

    render :show, status: :created
  end

  private

  def create_params
    params.require(:repo).permit(:name, :provider_uid_or_url)
  end

  def create_repo_class
    case params[:repo][:type]
    when 'gh'
      GithubRepo
    end
  end
end
