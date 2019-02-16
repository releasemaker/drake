class ApplicationController < ActionController::Base
  include Concerns::Navigation
  include Concerns::Authentication

  protect_from_forgery with: :exception

  def not_authenticated
    redirect_to sign_in_url
  end
end
