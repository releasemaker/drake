class ReposController < ApplicationController
  load_and_authorize_resource :repo

  def index
  end

  def new
  end
end
