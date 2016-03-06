# Shows the user their list of {Repo}s, allows them to edit their settings for a {Repo},
# enumerates available repos on SCM providers and allows them to
# create a {Repo} record for it.
class ReposController < ApplicationController
  load_and_authorize_resource :repo
  include PaginationHelper

  # Lists the current user's repositories.
  def index
  end

  # Lists the available repositories on available SCM providers, and provides a form
  # for each that points to the {#create} action.
  def new
  end

  # Creates a {Repo} record based on the form submission from the {#new} view.
  # There is an assumption that this will succeed, since there is no user-editable form.
  def create
    @repo.enabled = true
    @repo.save!
    redirect_to @repo
  end

  private

  def create_params
    params.require(:repo).permit(:type, :name, :provider_uid_or_url)
  end
end
