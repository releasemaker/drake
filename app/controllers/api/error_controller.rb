class Api::ErrorController < ApplicationApiController
  do_not_require_login
  skip_authorization_check

  def not_found
    head :not_found
  end
end
