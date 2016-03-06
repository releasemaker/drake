class ReposController < ApplicationController
  load_and_authorize_resource :repo

  def index
  end

  def new
  end

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
