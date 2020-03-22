class ApplicationApiController < ActionController::Base
  include AuthenticatesRequests

  protect_from_forgery with: :null_session

  def not_authenticated
    head :forbidden
  end
end
