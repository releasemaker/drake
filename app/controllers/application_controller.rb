class ApplicationController < ActionController::Base
  include DisplaysNavigation
  include AuthenticatesRequests

  protect_from_forgery with: :exception

  def not_authenticated
    redirect_to sign_in_url
  end
end
