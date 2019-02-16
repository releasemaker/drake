class Api::ReposController < ApplicationApiController
  include PaginationHelper

  def index
    authorize! :index, Repo
    @repos = current_user.repos.page(page).per(per_page)
    @paginated_content = @repos
  end

  def show
    @repo = repo_presenter.repo
    authorize! :show, @repo
  rescue Github::Error::NotFound
    raise ActionController::RoutingError.new('Not Found')
  end

  # Creates a {Repo} record based on the form submission from the {#new} view.
  # There is an assumption that this will succeed, since there is no user-editable form.
  def create
    Repo.transaction do
      @repo = repo_presenter.repo
      authorize! :create, @repo
      @repo.update! enabled: true

      RepoProviderWebhookService.new(@repo).perform!
    end

    render :show, status: :created
  end

  def update
    Repo.transaction do
      @repo = repo_presenter.repo
      authorize! :update, @repo
      @repo.update! repo_params

      RepoProviderWebhookService.new(@repo).perform!
    end

    render :show
  end

  private

  ##
  # Used by actions that need the existing repo for show, update, etc.
  def repo_presenter
    @repo_presenter = PresentGithubRepoByName.new(
      owner_name: params[:owner_name],
      repo_name: params[:repo_name],
      user: current_user,
    )
  end

  def repo_params
    {}.tap do |repo_params|
      repo_params[:enabled] = params[:repo][:isEnabled] if params[:repo].key? :isEnabled
    end
  end

  def repo_model
    case params[:repo_type] || params[:repo][:repoType]
    when 'gh'
      GithubRepo
    else
      raise "Unknown repo type"
    end
  end
end
