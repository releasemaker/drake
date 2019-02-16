class ApplicationApiController < ActionController::Base
  include Concerns::Authentication

  protect_from_forgery with: :null_session

  def not_authenticated
    head :forbidden
  end
end
